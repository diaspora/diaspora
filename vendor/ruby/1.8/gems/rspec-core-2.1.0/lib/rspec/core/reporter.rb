module RSpec::Core
  class Reporter
    def initialize(*formatters)
      @formatters = formatters
      @example_count = @failure_count = @pending_count = 0
      @duration = @start = nil
    end

    def report(count)
      start(count)
      begin
        yield self
      ensure
        conclude
      end
    end

    def conclude
      begin
        stop
        notify :start_dump
        notify :dump_pending
        notify :dump_failures
        notify :dump_summary, @duration, @example_count, @failure_count, @pending_count
      ensure
        notify :close
      end
    end

    alias_method :abort, :conclude

    def start(expected_example_count)
      @start = Time.now
      notify :start, expected_example_count
    end

    def message(message)
      notify :message, message
    end

    def example_group_started(group)
      notify :example_group_started, group
    end

    def example_group_finished(group)
      notify :example_group_finished, group
    end

    def example_started(example)
      @example_count += 1
      notify :example_started, example
    end

    def example_passed(example)
      notify :example_passed, example
    end

    def example_failed(example)
      @failure_count += 1
      notify :example_failed, example
    end

    def example_pending(example)
      @pending_count += 1
      notify :example_pending, example
    end

    def stop
      @duration = Time.now - @start if @start
      notify :stop
    end

    def notify(method, *args, &block)
      @formatters.each do |formatter|
        formatter.send method, *args, &block
      end
    end
  end
end
