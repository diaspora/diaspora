require 'rack/utils'
module Faraday
  module Utils
    include Rack::Utils

    extend Rack::Utils
    extend self

    HEADERS = Hash.new do |h, k|
      if k.respond_to?(:to_str)
        k
      else
        k.to_s.split('_').            # :user_agent => %w(user agent)
          each { |w| w.capitalize! }. # => %w(User Agent)
          join('-')                   # => "User-Agent"
      end
    end

    HEADERS.merge! :etag => "ETag"
    HEADERS.values.each { |v| v.freeze }

    # Make Rack::Utils build_query method public.
    public :build_query

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

    # Turns headers keys and values into strings.  Look up symbol keys in the
    # the HEADERS hash.
    #
    #   h = merge_headers(HeaderHash.new, :content_type => 'text/plain')
    #   h['Content-Type'] # = 'text/plain'
    #
    def merge_headers(existing_headers, new_headers)
      new_headers.each do |key, value|
        existing_headers[HEADERS[key]] = value.to_s
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
