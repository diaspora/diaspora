require 'cgi'

module RestClient

  module AbstractResponse

    attr_reader :net_http_res, :args

    # HTTP status code
    def code
      @code ||= @net_http_res.code.to_i
    end

    # A hash of the headers, beautified with symbols and underscores.
    # e.g. "Content-type" will become :content_type.
    def headers
      @headers ||= AbstractResponse.beautify_headers(@net_http_res.to_hash)
    end

    # The raw headers.
    def raw_headers
      @raw_headers ||= @net_http_res.to_hash
    end

    # Hash of cookies extracted from response headers
    def cookies
      @cookies ||= (self.headers[:set_cookie] || {}).inject({}) do |out, cookie_content|
        out.merge parse_cookie(cookie_content)
      end
    end

    # Return the default behavior corresponding to the response code:
    # the response itself for code in 200..206, redirection for 301, 302 and 307 in get and head cases, redirection for 303 and an exception in other cases
    def return! request  = nil, result = nil, & block
      if (200..207).include? code
        self
      elsif [301, 302, 307].include? code
        unless [:get, :head].include? args[:method]
          raise Exceptions::EXCEPTIONS_MAP[code].new(self, code)
        else
          follow_redirection(request, result, & block)
        end
      elsif code == 303
        args[:method] = :get
        args.delete :payload
        follow_redirection(request, result, & block)
      elsif Exceptions::EXCEPTIONS_MAP[code]
        raise Exceptions::EXCEPTIONS_MAP[code].new(self, code)
      else
        raise RequestFailed self
      end
    end

    def to_i
      code
    end

    def description
      "#{code} #{STATUSES[code]} | #{(headers[:content_type] || '').gsub(/;.*$/, '')} #{size} bytes\n"
    end

    # Follow a redirection
    def follow_redirection request = nil, result = nil, & block
      url = headers[:location]
      if url !~ /^http/
        url = URI.parse(args[:url]).merge(url).to_s
      end
      args[:url] = url
      if request
        args[:password] = request.password
        args[:user] = request.user
        args[:headers] = request.headers
        # pass any cookie set in the result
        if result && result['set-cookie']
          args[:headers][:cookies] = (args[:headers][:cookies] || {}).merge(parse_cookie(result['set-cookie']))
        end
      end
      Request.execute args, &block
    end

    def AbstractResponse.beautify_headers(headers)
      headers.inject({}) do |out, (key, value)|
        out[key.gsub(/-/, '_').downcase.to_sym] = %w{ set-cookie }.include?(key.downcase) ? value : value.first
        out
      end
    end

    private

    # Parse a cookie value and return its content in an Hash
    def parse_cookie cookie_content
      out = {}
      CGI::Cookie::parse(cookie_content).each do |key, cookie|
        unless ['expires', 'path'].include? key
          out[CGI::escape(key)] = cookie.value[0] ? (CGI::escape(cookie.value[0]) || '') : ''
        end
      end
      out
    end
  end

end
