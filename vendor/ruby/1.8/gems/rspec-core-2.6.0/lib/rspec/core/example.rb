module RSpec
  module Core
    class Example

      attr_reader :metadata, :options, :example_group_instance

      def self.delegate_to_metadata(*keys)
        keys.each do |key|
          define_method(key) {@metadata[key]}
        end
      end

      delegate_to_metadata :description, :full_description, :execution_result, :file_path, :pending, :location

      def initialize(example_group_class, desc, options, example_block=nil)
        @example_group_class, @options, @example_block = example_group_class, options, example_block
        @metadata  = @example_group_class.metadata.for_example(desc, options)
        @exception = nil
        @pending_declared_in_example = false
      end

      def example_group
        @example_group_class
      end

      def around_hooks
        @around_hooks ||= example_group.around_hooks_for(self)
      end

      def apply?(predicate, filters)
        @metadata.apply?(predicate, filters) ||
        @example_group_class.apply?(predicate, filters)
      end

      alias_method :pending?, :pending

      def run(example_group_instance, reporter)
        @example_group_instance = example_group_instance
        @example_group_instance.example = self

        start(reporter)

        begin
          unless pending
            with_around_hooks do
              begin
                run_before_each
                @example_group_instance.instance_eval(&@example_block)
              rescue Pending::PendingDeclaredInExample => e
                @pending_declared_in_example = e.message
              rescue Exception => e
                set_exception(e)
              ensure
                run_after_each
              end
            end
          end
        rescue Exception => e
          set_exception(e)
        ensure
          @example_group_instance.instance_variables.each do |ivar|
            @example_group_instance.instance_variable_set(ivar, nil)
          end
          @example_group_instance = nil

          begin
            assign_auto_description
          rescue Exception => e
            set_exception(e)
          end
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

      def self.procsy(metadata, &block)
        Proc.new(&block).extend(Procsy).with(metadata)
      end

      module Procsy
        attr_reader :metadata

        def self.extended(object)
          def object.run; call; end
        end

        def with(metadata)
          @metadata = metadata
          self
        end
      end

    private

      def with_around_hooks(&block)
        if around_hooks.empty?
          yield
        else
          @example_group_class.eval_around_eachs(self, Example.procsy(metadata, &block)).call
        end
      end

      def start(reporter)
        reporter.example_started(self)
        record :started_at => Time.now
      end

      def finish(reporter)
        if @exception
          record_finished 'failed', :exception => @exception
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
        @example_group_class.eval_before_eachs(self)
      end

      def run_after_each
        @example_group_class.eval_after_eachs(self)
        @example_group_instance.verify_mocks_for_rspec if @example_group_instance.respond_to?(:verify_mocks_for_rspec)
      ensure
        @example_group_instance.teardown_mocks_for_rspec if @example_group_instance.respond_to?(:teardown_mocks_for_rspec)
      end

      def assign_auto_description
        if description.empty? and !pending?
          if RSpec.configuration.expecting_with_rspec?
            metadata[:description] = RSpec::Matchers.generated_description
            RSpec::Matchers.clear_generated_description
          else
            raise NotImplementedError.new(
              "Generated descriptions are only supported when you use rspec-expectations.  " +
              "You must give every example an explicit description."
            )
          end
        end
      end

      def record(results={})
        execution_result.update(results)
      end

    end
  end
end
