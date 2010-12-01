module RSpec
  module Core
    class Example

      attr_reader :metadata, :options

      def self.delegate_to_metadata(*keys)
        keys.each do |key|
          define_method(key) {@metadata[key]}
        end
      end

      delegate_to_metadata :description, :full_description, :execution_result, :file_path, :pending

      def initialize(example_group_class, desc, options, example_block=nil)
        @example_group_class, @options, @example_block = example_group_class, options, example_block
        @metadata  = @example_group_class.metadata.for_example(desc, options)
        @exception = nil
        @pending_declared_in_example = false
      end

      def example_group
        @example_group_class
      end

      def pending?
        !!pending
      end

      def run(example_group_instance, reporter)
        @example_group_instance = example_group_instance
        @example_group_instance.example = self

        start(reporter)

        begin
          unless pending
            with_pending_capture do
              with_around_hooks do
                begin
                  run_before_each
                  @example_group_instance.instance_eval(&@example_block)
                rescue Exception => e
                  set_exception(e)
                ensure
                  run_after_each
                end
              end
            end
          end
        rescue Exception => e
          set_exception(e)
        ensure
          @example_group_instance.example = nil
          assign_auto_description
        end

        finish(reporter)
      end

      def set_exception(exception)
        @exception ||= exception
      end

      def fail_fast(reporter, exception)
        start(reporter)
        set_exception(exception)
        finish(reporter)
      end

    private

      def with_pending_capture(&block)
        @pending_declared_in_example = catch(:pending_declared_in_example) do
          block.call
          throw :pending_declared_in_example, false
        end
      end

      def with_around_hooks(&wrapped_example)
        @example_group_class.eval_around_eachs(@example_group_instance, wrapped_example).call
      end

      def start(reporter)
        reporter.example_started(self)
        record :started_at => Time.now
      end

      def finish(reporter)
        if @exception
          record_finished 'failed', :exception_encountered => @exception
          reporter.example_failed self
          false
        elsif @pending_declared_in_example
          record_finished 'pending', :pending_message => @pending_declared_in_example
          reporter.example_pending self
          true
        elsif pending
          record_finished 'pending', :pending_message => 'Not Yet Implemented'
          reporter.example_pending self
          true
        else
          record_finished 'passed'
          reporter.example_passed self
          true
        end
      end

      def record_finished(status, results={})
        finished_at = Time.now
        record results.merge(:status => status, :finished_at => finished_at, :run_time => (finished_at - execution_result[:started_at]))
      end

      def run_before_each
        @example_group_instance.setup_mocks_for_rspec if @example_group_instance.respond_to?(:setup_mocks_for_rspec)
        @example_group_class.eval_before_eachs(@example_group_instance)
      end

      def run_after_each
        @example_group_class.eval_after_eachs(@example_group_instance)
        @example_group_instance.verify_mocks_for_rspec if @example_group_instance.respond_to?(:verify_mocks_for_rspec)
      ensure
        @example_group_instance.teardown_mocks_for_rspec if @example_group_instance.respond_to?(:teardown_mocks_for_rspec)
      end

      def assign_auto_description
        if description.empty? and !pending?
          metadata[:description] = RSpec::Matchers.generated_description
          RSpec::Matchers.clear_generated_description
        end
      end

      def record(results={})
        execution_result.update(results)
      end

    end
  end
end
