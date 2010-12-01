module Cucumber
  module RbSupport
    # All steps are run in the context of an object that extends this module.
    module RbWorld
      class << self
        def alias_adverb(adverb)
          alias_method adverb, :__cucumber_invoke
        end
      end

      # Call a Transform with a string from another Transform definition
      def Transform(arg)
        rb = @__cucumber_step_mother.load_programming_language('rb')
        rb.execute_transforms([arg]).first
      end
    
      attr_writer :__cucumber_step_mother, :__natural_language

      # Call a step from within a step definition. This method is aliased to
      # the same i18n as RbDsl.
      def __cucumber_invoke(name, multiline_argument=nil) #:nodoc:
        @__cucumber_step_mother.invoke(name, multiline_argument)
      end

      # See StepMother#invoke_steps
      def steps(steps_text)
        @__cucumber_step_mother.invoke_steps(steps_text, @__natural_language, caller[0])
      end

      # See StepMother#table
      def table(text_or_table, file=nil, line_offset=0)
        @__cucumber_step_mother.table(text_or_table, file, line_offset)
      end

      # See StepMother#py_string
      def py_string(string_with_triple_quotes, file=nil, line_offset=0)
        @__cucumber_step_mother.py_string(string_with_triple_quotes, file, line_offset)
      end

      # See StepMother#announce
      def announce(announcement)
        @__cucumber_step_mother.announce(announcement)
      end

      # See StepMother#ask
      def ask(question, timeout_seconds=60)
        @__cucumber_step_mother.ask(question, timeout_seconds)
      end

      # See StepMother#embed
      def embed(file, mime_type)
        @__cucumber_step_mother.embed(file, mime_type)
      end

      # Prints out the world class, followed by all included modules.
      def announce_world
        announce "WORLD:\n  #{self.class}"
        world = self
        (class << self; self; end).instance_eval do
          world.announce "  #{included_modules.join("\n  ")}"
        end
      end

      # Mark the matched step as pending.
      def pending(message = "TODO")
        if block_given?
          begin
            yield
          rescue Exception => e
            raise Pending.new(message)
          end
          raise Pending.new("Expected pending '#{message}' to fail. No Error was raised. No longer pending?")
        else
          raise Pending.new(message)
        end
      end

      # The default implementation of Object#inspect recursively
      # traverses all instance variables and invokes inspect. 
      # This can be time consuming if the object graph is large.
      #
      # This can cause unnecessary delays when certain exceptions 
      # occur. For example, MRI internally invokes #inspect on an 
      # object that raises a NoMethodError. (JRuby does not do this).
      #
      # A World object can have many references created by the user
      # or frameworks (Rails), so to avoid long waiting times on
      # such errors in World we define it to just return a simple String.
      #
      def inspect #:nodoc:
        sprintf("#<%s:0x%x>", self.class, self.object_id)
      end
    end
  end
end
