require 'rack/utils'
module Faraday
  module Utils
    include Rack::Utils

    extend Rack::Utils
    extend self

    class Headers < HeaderHash
      # symbol -> string mapper + cache
      KeyMap = Hash.new do |map, key|
        map[key] = if key.respond_to?(:to_str) then key
        else
          key.to_s.split('_').            # :user_agent => %w(user agent)
            each { |w| w.capitalize! }.   # => %w(User Agent)
            join('-')                     # => "User-Agent"
        end
      end
      KeyMap[:etag] = "ETag"
      
      def [](k)
        super(KeyMap[k])
      end

      def []=(k, v)
        # join multiple values with a comma
        v = v.to_ary.join(', ') if v.respond_to? :to_ary
        super(KeyMap[k], v)
      end
      
      alias_method :update, :merge!
      
      def parse(header_string)
        return unless header_string && !header_string.empty?
        header_string.split(/\r\n/).
          tap  { |a| a.shift if a.first.index('HTTP/') == 0 }. # drop the HTTP status line
          map  { |h| h.split(/:\s+/, 2) }.reject { |(k, v)| k.nil? }. # split key and value, ignore blank lines
          each { |key, value|
            # join multiple values with a comma
            if self[key] then self[key] << ', ' << value
            else self[key] = value
            end
          }
      end
    end

    # Make Rack::Utils build_query method public.
    public :build_query

    # Override Rack's version since it doesn't handle non-String values
    def build_nested_query(value, prefix = nil)
      case value
      when Array
        value.map { |v| build_nested_query(v, "#{prefix}[]") }.join("&")
      when Hash
        value.map { |k, v|
          build_nested_query(v, prefix ? "#{prefix}[#{escape(k)}]" : escape(k))
        }.join("&")
      when NilClass
        prefix
      else
        raise ArgumentError, "value must be a Hash" if prefix.nil?
        "#{prefix}=#{escape(value)}"
      end
    end

    # Be sure to URI escape '+' symbols to %2B. Otherwise, they get interpreted
    # as spaces.
    def escape(s)
      s.to_s.gsub(/([^a-zA-Z0-9_.-]+)/n) do
        '%' << $1.unpack('H2'*bytesize($1)).join('%').tap { |c| c.upcase! }
      end
    end

    # Turns param keys into strings
    def merge_params(existing_params, new_params)
      new_params.each do |key, value|
        existing_params[key.to_s] = value
      end
    end

    # Turns headers keys and values into strings
    def merge_headers(existing_headers, new_headers)
      new_headers.each do |key, value|
        existing_headers[key] = value.to_s
      end
    end

    # Receives a URL and returns just the path with the query string sorted.
    def normalize_path(url)
      (url.path != "" ? url.path : "/") +
      (url.query ? "?#{sort_query_params(url.query)}" : "")
    end

    protected

    def sort_query_params(query)
      query.split('&').sort.join('&')
    end
  end
end
