require 'spec/runner/formatter/progress_bar_formatter'

module RSpec
  class Instafail < Spec::Runner::Formatter::ProgressBarFormatter
    def example_failed(example, counter, failure)
      short_padding = '  '
      padding = '     '

      output.puts
      output.puts red("#{short_padding}#{counter}) #{example_group.description} #{example.description}")
      output.puts "#{padding}#{red(failure.exception)}"

      [*format_backtrace(failure.exception.backtrace)].each do |backtrace_info|
        output.puts insta_gray("#{padding}# #{backtrace_info.strip}")
      end

      output.flush
    end

    private

    # there is a gray() that returns nil, so we use our own...
    def insta_gray(text)
      colour(text, "\e[90m")
    end
  end
end
