require 'rspec/core/formatters/progress_formatter'

module RSpec
  class Instafail < RSpec::Core::Formatters::ProgressFormatter
    def example_failed(example)
      @counter ||= 0
      @counter += 1
      exception = example.metadata[:execution_result][:exception_encountered]
      short_padding = '  '
      padding = '     '
      output.puts
      output.puts "#{short_padding}#{@counter}) #{example.full_description}"
      output.puts "#{padding}#{red("Failure/Error:")} #{red(read_failed_line(exception, example).strip)}"
      output.puts "#{padding}#{red(exception)}"
      format_backtrace(exception.backtrace, example).each do |backtrace_info|
        output.puts grey("#{padding}# #{backtrace_info}")
      end
      output.flush
    end
  end
end
