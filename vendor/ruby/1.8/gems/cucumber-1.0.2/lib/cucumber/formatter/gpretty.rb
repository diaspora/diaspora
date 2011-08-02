require 'cucumber/formatter/gherkin_formatter_adapter'
require 'cucumber/formatter/io'
require 'gherkin/formatter/argument'
require 'gherkin/formatter/pretty_formatter'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format gpretty</tt>
    class Gpretty < GherkinFormatterAdapter
      include Io

      def initialize(step_mother, io, options)
        @io = ensure_io(io, "json")
        super(Gherkin::Formatter::PrettyFormatter.new(@io, false), true)
      end

      def after_feature(feature)
        super
        @io.puts
      end
    end
  end
end

