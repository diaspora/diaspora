module Addressable
  class URI
    module CharacterClasses
      USERINFO = UNRESERVED + SUB_DELIMS + "\\:"
    end
  end
end

module WebMock

  module Util

    class URI
      ADDRESSABLE_URIS = Hash.new do |hash, key|
        hash[key] = Addressable::URI.heuristic_parse(key)
      end

      NORMALIZED_URIS = Hash.new do |hash, uri|
        normalized_uri = WebMock::Util::URI.heuristic_parse(uri)
        normalized_uri.query_values = sort_query_values(normalized_uri.query_values) if normalized_uri.query_values
        normalized_uri = normalized_uri.normalize #normalize! is slower
        normalized_uri.port = normalized_uri.inferred_port unless normalized_uri.port
        hash[uri] = normalized_uri
      end

      def self.heuristic_parse(uri)
        ADDRESSABLE_URIS[uri].dup
      end

      def self.normalize_uri(uri)
        return uri if uri.is_a?(Regexp)
        uri = 'http://' + uri unless uri.match('^https?://') if uri.is_a?(String)
        NORMALIZED_URIS[uri].dup
      end

      def self.variations_of_uri_as_strings(uri_object)
        normalized_uri = normalize_uri(uri_object.dup).freeze
        uris = [ normalized_uri ]

        if normalized_uri.path == '/'
          uris = uris_with_trailing_slash_and_without(uris)
        end

        uris = uris_encoded_and_unencoded(uris)

        if normalized_uri.port == Addressable::URI.port_mapping[normalized_uri.scheme]
          uris = uris_with_inferred_port_and_without(uris)
        end

        if normalized_uri.scheme == "http"
          uris = uris_with_scheme_and_without(uris)
        end

        uris.map {|uri| uri.to_s.gsub(/^\/\//,'') }.uniq
      end

      def self.strip_default_port_from_uri_string(uri_string)
        case uri_string
        when %r{^http://}  then uri_string.sub(%r{:80(/|$)}, '\1')
        when %r{^https://} then uri_string.sub(%r{:443(/|$)}, '\1')
        else uri_string
        end
      end

      def self.encode_unsafe_chars_in_userinfo(userinfo)
        Addressable::URI.encode_component(userinfo, Addressable::URI::CharacterClasses::USERINFO)
      end

      def self.is_uri_localhost?(uri)
        uri.is_a?(Addressable::URI) && 
        %w(localhost 127.0.0.1 0.0.0.0).include?(uri.host)
      end

      private

      def self.sort_query_values(query_values)
        Hash[*query_values.sort.inject([]) { |values, pair| values + pair}]
      end

      def self.uris_with_inferred_port_and_without(uris)
        uris.map { |uri| [ uri, uri.gsub(%r{(:80)|(:443)}, "").freeze ] }.flatten
      end

      def self.uris_encoded_and_unencoded(uris)
        uris.map do |uri|
          [ uri.to_s, Addressable::URI.unencode(uri, String).freeze ]
        end.flatten
      end

      def self.uris_with_scheme_and_without(uris)
        uris.map { |uri| [ uri, uri.gsub(%r{^https?://},"").freeze ] }.flatten
      end

      def self.uris_with_trailing_slash_and_without(uris)
        uris = uris.map { |uri| [ uri, uri.omit(:path).freeze ] }.flatten
      end

    end
  end

end
