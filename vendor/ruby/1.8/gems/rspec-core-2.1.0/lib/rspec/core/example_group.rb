module RSpec
  module Core
    class ExampleGroup
      extend  Extensions::ModuleEvalWithArgs
      include Extensions::InstanceEvalWithArgs
      extend  Hooks
      extend  Subject::ClassMethods
      include Subject::InstanceMethods
      include Let
      include Pending

      attr_accessor :example

      def running_example
        RSpec.deprecate("running_example", "example")
        example
      end

      def self.world
        RSpec.world
      end

      def self.register
        RSpec::Core::Runner.autorun
        world.register(self)
      end

      class << self
        def self.delegate_to_metadata(*names)
          names.each do |name|
            define_method name do
              metadata[:example_group][name]
            end
          end
        end

        delegate_to_metadata :description, :describes, :file_path
        alias_method :display_name, :description
        alias_method :described_class, :describes
      end

      def self.define_example_method(name, extra_options={})
        module_eval(<<-END_RUBY, __FILE__, __LINE__)
          def self.#{name}(desc=nil, options={}, &block)
            options.update(:pending => true) unless block
            options.update(#{extra_options.inspect})
            examples << RSpec::Core::Example.new(self, desc, options, block)
            examples.last
          end
        END_RUBY
      end

      define_example_method :example

      class << self
        alias_method :alias_example_to, :define_example_method
      end

      alias_example_to :it
      alias_example_to :specify
      alias_example_to :focused, :focused => true
      alias_example_to :pending, :pending => true
      alias_example_to :xit,     :pending => true

      def self.define_shared_group_method(new_name, report_label=nil)
        module_eval(<<-END_RUBY, __FILE__, __LINE__)
          def self.#{new_name}(name, *args, &customization_block)
            shared_block = world.shared_example_groups[name]
            raise "Could not find shared example group named \#{name.inspect}" unless shared_block

            group = describe("#{report_label || "it should behave like"} \#{name}") do
              module_eval_with_args(*args, &shared_block)
              module_eval(&customization_block) if customization_block
            end
            group.metadata[:shared_group_name] = name
            group
          end
        END_RUBY
      end

      define_shared_group_method :it_should_behave_like

      class << self
        alias_method :alias_it_should_behave_like_to, :define_shared_group_method
      end

      alias_it_should_behave_like_to :it_behaves_like, "behaves like"

      def self.examples
        @examples ||= []
      end

      def self.filtered_examples
        world.filtered_examples[self]
      end

      def self.descendant_filtered_examples
        @descendant_filtered_examples ||= filtered_examples + children.inject([]){|l,c| l + c.descendant_filtered_examples}
      end

      def self.metadata
        @metadata if defined?(@metadata)
      end

      def self.superclass_metadata
        @superclass_metadata ||= self.superclass.respond_to?(:metadata) ? self.superclass.metadata : nil
      end

      def self.describe(*args, &example_group_block)
        @_subclass_count ||= 0
        @_subclass_count += 1
        args << {} unless args.last.is_a?(Hash)
        args.last.update(:example_group_block => example_group_block)

        # TODO 2010-05-05: Because we don't know if const_set is thread-safe
        child = const_set(
          "Nested_#{@_subclass_count}",
          subclass(self, args, &example_group_block)
        )
        children << child
        child
      end

      class << self
        alias_method :context, :describe
      end

      def self.subclass(parent, args, &example_group_block)
        subclass = Class.new(parent)
        subclass.set_it_up(*args)
        subclass.module_eval(&example_group_block) if example_group_block
        subclass
      end

      def self.children
        @children ||= []
      end

      def self.descendants
        @_descendants ||= [self] + children.inject([]) {|list, c| list + c.descendants}
      end

      def self.ancestors
        @_ancestors ||= super().select {|a| a < RSpec::Core::ExampleGroup}
      end

      def self.top_level?
        @top_level ||= superclass == ExampleGroup
      end

      def self.set_it_up(*args)
        @metadata = RSpec::Core::Metadata.new(superclass_metadata).process(*args)
        world.configure_group(self)
      end

      def self.before_all_ivars
        @before_all_ivars ||= {}
      end

      def self.store_before_all_ivars(example_group_instance)
        return if example_group_instance.instance_variables.empty?
        example_group_instance.instance_variables.each { |ivar| 
          before_all_ivars[ivar] = example_group_instance.instance_variable_get(ivar)
        }
      end

      def self.assign_before_all_ivars(ivars, example_group_instance)
        return if ivars.empty?
        ivars.each { |ivar, val| example_group_instance.instance_variable_set(ivar, val) }
      end

      def self.eval_before_alls(example_group_instance)
        return if descendant_filtered_examples.empty?
        assign_before_all_ivars(superclass.before_all_ivars, example_group_instance)
        world.run_hook_filtered(:before, :all, self, example_group_instance) if top_level?
        run_hook!(:before, :all, example_group_instance)
        store_before_all_ivars(example_group_instance)
      end

      def self.eval_around_eachs(example_group_instance, wrapped_example)
        around_hooks.reverse.inject(wrapped_example) do |wrapper, hook|
          def wrapper.run; call; end
          lambda { example_group_instance.instance_eval_with_args(wrapper, &hook) }
        end
      end

      def self.eval_before_eachs(example_group_instance)
        world.run_hook_filtered(:before, :each, self, example_group_instance)
        ancestors.reverse.each { |ancestor| ancestor.run_hook(:before, :each, example_group_instance) }
      end

      def self.eval_after_eachs(example_group_instance)
        ancestors.each { |ancestor| ancestor.run_hook(:after, :each, example_group_instance) }
        world.run_hook_filtered(:after, :each, self, example_group_instance)
      end

      def self.eval_after_alls(example_group_instance)
        return if descendant_filtered_examples.empty?
        assign_before_all_ivars(before_all_ivars, example_group_instance)

        begin
          run_hook!(:after, :all, example_group_instance)
        rescue => e
          # TODO: come up with a better solution for this.
          RSpec.configuration.reporter.message <<-EOS

An error occurred in an after(:all) hook.
  #{e.class}: #{e.message}
  occurred at #{e.backtrace.first}

        EOS
        end

        world.run_hook_filtered(:after, :all, self, example_group_instance) if top_level?
      end

      def self.around_hooks
        @around_hooks ||= (world.find_hook(:around, :each, self) + ancestors.reverse.inject([]){|l,a| l + a.find_hook(:around, :each, self)})
      end

      def self.run(reporter)
        if RSpec.wants_to_quit
          RSpec.clear_remaining_example_groups if top_level?
          return
        end
        example_group_instance = new
        reporter.example_group_started(self)

        begin
          eval_before_alls(example_group_instance)
          result_for_this_group = run_examples(example_group_instance, reporter)
          results_for_descendants = children.map {|child| child.run(reporter)}.all?
          result_for_this_group && results_for_descendants
        rescue Exception => ex
          fail_filtered_examples(ex, reporter)
        ensure
          eval_after_alls(example_group_instance)
          reporter.example_group_finished(self)
        end
      end

      def self.fail_filtered_examples(exception, reporter)
        filtered_examples.each { |example| example.fail_fast(reporter, exception) }

        children.each do |child|
          reporter.example_group_started(child)
          child.fail_filtered_examples(exception, reporter)
          reporter.example_group_finished(child)
        end
      end

      def self.fail_fast?
        RSpec.configuration.fail_fast?
      end

      def self.run_examples(instance, reporter)
        filtered_examples.map do |example|
          next if RSpec.wants_to_quit
          begin
            set_ivars(instance, before_all_ivars)
            succeeded = example.run(instance, reporter)
            RSpec.wants_to_quit = true if fail_fast? && !succeeded
            succeeded
          ensure
            clear_ivars(instance)
            clear_memoized(instance)
          end
        end.all?
      end

      def self.apply?(predicate, filters)
        metadata.apply?(predicate, filters)
      end

      def self.declaration_line_numbers
        @declaration_line_numbers ||= [metadata[:example_group][:line_number]] +
          examples.collect {|e| e.metadata[:line_number]} +
          children.inject([]) {|l,c| l + c.declaration_line_numbers}
      end

      def self.top_level_description
        ancestors.last.description
      end

      def self.set_ivars(instance, ivars)
        ivars.each {|name, value| instance.instance_variable_set(name, value)}
      end

      def self.clear_ivars(instance)
        instance.instance_variables.each { |ivar| instance.send(:remove_instance_variable, ivar) }
      end

      def self.clear_memoized(instance)
        instance.__memoized.clear
      end

      def described_class
        self.class.described_class
      end

      def instance_eval_with_rescue(&hook)
        begin
          instance_eval(&hook)
        rescue Exception => e
          raise unless example
          example.set_exception(e)
        end
      end
    end
  end
end
