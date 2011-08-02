require 'cucumber/formatter/gherkin_formatter_adapter'
require 'cucumber/formatter/io'
require 'gherkin/formatter/argument'
require 'gherkin/formatter/json_formatter'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format json</tt>
    class Json < GherkinFormatterAdapter
      include Io

      def initialize(step_mother, io, options)
        @io = ensure_io(io, "json")
        @io.write('{"features":[')
        super(Gherkin::Formatter::JSONFormatter.new(@io), false)
      end

      def before_feature(feature)
        super
        @io.write(',') if @one
        @one = true
      end

      def after_features(features)
        @io.write(']}')
        @io.flush
      end
    end
  end
end

