module FaradayStack
  # A base class for middleware that parses responses
  class ResponseMiddleware < Faraday::Response::Middleware
    CONTENT_TYPE = 'Content-Type'.freeze

    class << self
      attr_accessor :parser
    end

    # Stores a block that receives the body and should return a parsed result
    def self.define_parser(&block)
      @parser = block
    end

    def self.inherited(subclass)
      super
      subclass.load_error = self.load_error
      subclass.parser = self.parser
    end

    def initialize(app = nil, options = {})
      super(app)
      @options = options
      @content_types = Array(options[:content_type])
    end

    # Override this to modify the environment after the response has finished.
    def on_complete(env)
      if process_response_type?(response_type(env)) and parse_response?(env)
        env[:body] = parse(env[:body])
      end
    end

    # Parses the response body and returns the result.
    # Instead of overriding this method, consider using `define_parser`
    def parse(body)
      if self.class.parser
        begin
          self.class.parser.call(body)
        rescue
          raise Faraday::Error::ParsingError, $!
        end
      else
        body
      end
    end

    def response_type(env)
      type = env[:response_headers][CONTENT_TYPE].to_s
      type = type.split(';', 2).first if type.index(';')
      type
    end
    
    def process_response_type?(type)
      @content_types.empty? or @content_types.any? { |pattern|
        Regexp === pattern ? type =~ pattern : type == pattern
      }
    end
    
    def parse_response?(env)
      env[:body].respond_to? :to_str
    end
  end
end
