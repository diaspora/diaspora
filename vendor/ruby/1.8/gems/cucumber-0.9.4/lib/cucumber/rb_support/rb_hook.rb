module Cucumber
  module RbSupport
    # Wrapper for Before, After and AfterStep hooks
    class RbHook
      attr_reader :tag_expressions

      def initialize(rb_language, tag_expressions, proc)
        @rb_language = rb_language
        @tag_expressions = tag_expressions
        @proc = proc
      end

      def invoke(location, argument, &block)
        @rb_language.current_world.cucumber_instance_exec(false, location, *[argument, block].compact, &@proc)
      end
    end
  end
end
