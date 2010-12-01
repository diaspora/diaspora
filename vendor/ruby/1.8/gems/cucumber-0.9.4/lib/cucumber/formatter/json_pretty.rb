require "cucumber/formatter/json"

module Cucumber
  module Formatter
    # The formatter used for <tt>--format json_pretty</tt>
    class JsonPretty < Json

      def json_string
        JSON.pretty_generate @json
      end

    end
  end
end