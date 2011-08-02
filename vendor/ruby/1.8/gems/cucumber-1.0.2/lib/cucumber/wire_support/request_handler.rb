module Cucumber
  module WireSupport
    class RequestHandler
      def initialize(connection)
        @connection = connection
        @message = underscore(self.class.name.split('::').last)
      end

      def execute(request_params = nil)
        @connection.call_remote(self, @message, request_params)
      end

      def handle_fail(params)
        raise @connection.exception(params)
      end
      
      def handle_success(params)
      end
      
      private
      
      # Props to Rails
      def underscore(camel_cased_word)
        camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
      end
    end
  end
end
