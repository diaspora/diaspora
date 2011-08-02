module FaradayStack
  class ResponseJSON < ResponseMiddleware
    adapter_name = nil

    # loads the JSON decoder either from yajl-ruby or activesupport
    dependency do
      require 'yajl'
      adapter_name = Yajl::Parser.name
    end

    dependency do
      require 'active_support/json/decoding'
      adapter_name = ActiveSupport::JSON.name
    end unless loaded?

    # defines a parser block depending on which adapter has loaded
    case adapter_name
    when 'Yajl::Parser'
      define_parser do |body|
        Yajl::Parser.parse(body)
      end
    when 'ActiveSupport::JSON'
      define_parser do |body|
        unless body.nil? or body.empty?
          result = ActiveSupport::JSON.decode(body)
          raise ActiveSupport::JSON.backend::ParseError if String === result
          result
        end
      end
    end

    # writes the correct MIME-type if the payload looks like JSON
    class MimeTypeFix < ResponseMiddleware
      def on_complete(env)
        if process_response_type?(response_type(env)) and looks_like_json?(env)
          old_type = env[:response_headers][CONTENT_TYPE]
          new_type = 'application/json'
          new_type << ';' << old_type.split(';', 2).last if old_type.index(';')
          env[:response_headers][CONTENT_TYPE] = new_type
        end
      end

      BRACKETS = %w- [ { -

      def looks_like_json?(env)
        parse_response?(env) and BRACKETS.include? env[:body][0,1]
      end
    end
  end
end
