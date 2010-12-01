module Cucumber
  module WireSupport
    class WireStepDefinition
      attr_reader :regexp_source, :file_colon_line
      
      def initialize(connection, data)
        @connection = connection
        @id              = data['id']
        @regexp_source   = data['regexp'] || "Unknown"
        @file_colon_line = data['source'] || "Unknown"
      end
      
      def invoke(args)
        prepared_args = args.map{ |arg| prepare(arg) }
        @connection.invoke(@id, prepared_args)
      end

      private
      
      def prepare(arg)
        return arg unless arg.is_a?(Cucumber::Ast::Table)
        arg.raw
      end
    end
  end
end