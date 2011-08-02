require 'openssl'
require 'base64'

module OAuth
  module Helper
    extend self

    # Escape +value+ by URL encoding all non-reserved character.
    #
    # See Also: {OAuth core spec version 1.0, section 5.1}[http://oauth.net/core/1.0#rfc.section.5.1]
    def escape(value)
      URI::escape(value.to_s, OAuth::RESERVED_CHARACTERS)
    rescue ArgumentError
      URI::escape(value.to_s.force_encoding(Encoding::UTF_8), OAuth::RESERVED_CHARACTERS)
    end

    # Generate a random key of up to +size+ bytes. The value returned is Base64 encoded with non-word
    # characters removed.
    def generate_key(size=32)
      Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
    end

    alias_method :generate_nonce, :generate_key

    def generate_timestamp #:nodoc:
      Time.now.to_i.to_s
    end

    # Normalize a +Hash+ of parameter values. Parameters are sorted by name, using lexicographical
    # byte value ordering. If two or more parameters share the same name, they are sorted by their value.
    # Parameters are concatenated in their sorted order into a single string. For each parameter, the name
    # is separated from the corresponding value by an "=" character, even if the value is empty. Each
    # name-value pair is separated by an "&" character.
    #
    # See Also: {OAuth core spec version 1.0, section 9.1.1}[http://oauth.net/core/1.0#rfc.section.9.1.1]
    def normalize(params)
      params.sort.map do |k, values|

        if values.is_a?(Array)
          # multiple values were provided for a single key
          values.sort.collect do |v|
            [escape(k),escape(v)] * "="
          end
        else
          [escape(k),escape(values)] * "="
        end
      end * "&"
    end

    # Parse an Authorization / WWW-Authenticate header into a hash. Takes care of unescaping and
    # removing surrounding quotes. Raises a OAuth::Problem if the header is not parsable into a
    # valid hash. Does not validate the keys or values.
    #
    #   hash = parse_header(headers['Authorization'] || headers['WWW-Authenticate'])
    #   hash['oauth_timestamp']
    #     #=>"1234567890"
    #
    def parse_header(header)
      # decompose
      params = header[6,header.length].split(/[,=&]/)

      # odd number of arguments - must be a malformed header.
      raise OAuth::Problem.new("Invalid authorization header") if params.size % 2 != 0

      params.map! do |v|
        # strip and unescape
        val = unescape(v.strip)
        # strip quotes
        val.sub(/^\"(.*)\"$/, '\1')
      end

      # convert into a Hash
      Hash[*params.flatten]
    end

    def unescape(value)
      URI.unescape(value.gsub('+', '%2B'))
    end

    def stringify_keys(hash)
      new_h = {}
      hash.each do |k, v|
        new_h[k.to_s] = v.is_a?(Hash) ? stringify_keys(v) : v
      end
      new_h
    end
  end
end
