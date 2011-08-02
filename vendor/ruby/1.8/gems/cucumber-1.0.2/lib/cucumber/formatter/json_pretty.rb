require 'cucumber/formatter/json'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format json_pretty</tt>
    class JsonPretty < Json
      def after_features(features)
        @io.write(JSON.pretty_generate(@obj))
      end
    end
  end
end

