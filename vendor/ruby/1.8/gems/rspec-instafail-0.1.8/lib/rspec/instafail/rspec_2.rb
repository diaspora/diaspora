require 'rspec/core/formatters/progress_formatter'

module RSpec
  class Instafail < RSpec::Core::Formatters::ProgressFormatter
    def example_failed(example)
      @counter ||= 0
      @counter += 1

      result = example.metadata[:execution_result]

      exception = result[:exception_encountered] || result[:exception] # rspec 2.0 || rspec 2.2
      short_padding = '  '
      padding = '     '
      output.puts
      output.puts "#{short_padding}#{@counter}) #{example.full_description}"
      output.puts "#{padding}#{red("Failure/Error:")} #{red(read_failed_line(exception, example).strip)}"
      output.puts "#{padding}#{red(exception)}"
      if exception.respond_to?(:original_exception)
        output.puts "#{padding}#{red(exception.original_exception)}"
      end
      format_backtrace(exception.backtrace, example).each do |backtrace_info|
        color = defined?(cyan) ? :cyan : :grey # cyan was added in rspec 2.6
        output.puts send(color, "#{padding}# #{backtrace_info}")
      end
      output.flush
    end
  end
end
