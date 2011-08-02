module Fog
  class Connection

    def initialize(url, persistent=false)
      @excon = Excon.new(url)
      @persistent = persistent
    end

    def request(params, &block)
      unless @persistent
        reset
      end
      unless block_given?
        if (parser = params.delete(:parser))
          body = Nokogiri::XML::SAX::PushParser.new(parser)
          block = lambda { |chunk| body << chunk }
        end
      end

      response = @excon.request(params, &block)

      if parser
        body.finish
        response.body = parser.response
      end

      response
    end

    def reset
      @excon.reset
    end

  end
end
