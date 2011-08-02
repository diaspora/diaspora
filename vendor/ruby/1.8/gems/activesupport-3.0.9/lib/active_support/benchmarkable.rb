require 'active_support/core_ext/benchmark'
require 'active_support/core_ext/hash/keys'

module ActiveSupport
  module Benchmarkable
    # Allows you to measure the execution time of a block
    # in a template and records the result to the log. Wrap this block around
    # expensive operations or possible bottlenecks to get a time reading
    # for the operation.  For example, let's say you thought your file
    # processing method was taking too long; you could wrap it in a benchmark block.
    #
    #  <% benchmark "Process data files" do %>
    #    <%= expensive_files_operation %>
    #  <% end %>
    #
    # That would add something like "Process data files (345.2ms)" to the log,
    # which you can then use to compare timings when optimizing your code.
    #
    # You may give an optional logger level as the :level option.
    # (:debug, :info, :warn, :error); the default value is :info.
    #
    #  <% benchmark "Low-level files", :level => :debug do %>
    #    <%= lowlevel_files_operation %>
    #  <% end %>
    #
    # Finally, you can pass true as the third argument to silence all log activity
    # inside the block. This is great for boiling down a noisy block to just a single statement:
    #
    #  <% benchmark "Process data files", :level => :info, :silence => true do %>
    #    <%= expensive_and_chatty_files_operation %>
    #  <% end %>
    def benchmark(message = "Benchmarking", options = {})
      if logger
        if options.is_a?(Symbol)
          ActiveSupport::Deprecation.warn("use benchmark('#{message}', :level => :#{options}) instead", caller)
          options = { :level => options, :silence => false }
        else
          options.assert_valid_keys(:level, :silence)
          options[:level] ||= :info
        end

        result = nil
        ms = Benchmark.ms { result = options[:silence] ? logger.silence { yield } : yield }
        logger.send(options[:level], '%s (%.1fms)' % [ message, ms ])
        result
      else
        yield
      end
    end

    # Silence the logger during the execution of the block.
    #
    def silence
      old_logger_level, logger.level = logger.level, ::Logger::ERROR if logger
      yield
    ensure
      logger.level = old_logger_level if logger
    end
  end
end
