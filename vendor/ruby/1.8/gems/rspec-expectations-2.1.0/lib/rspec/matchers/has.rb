module RSpec
  module Matchers
    
    class Has
      
      def initialize(expected, *args)
        @expected, @args = expected, args
      end
      
      def matches?(actual)
        actual.__send__(predicate(@expected), *@args)
      end
      
      def failure_message_for_should
        "expected ##{predicate(@expected)}(#{@args[0].inspect}) to return true, got false"
      end
      
      def failure_message_for_should_not
        "expected ##{predicate(@expected)}(#{@args[0].inspect}) to return false, got true"
      end
      
      def description
        "have key #{@args[0].inspect}"
      end
    
    private
    
      def predicate(sym)
        "#{sym.to_s.sub("have_","has_")}?".to_sym
      end
      
    end
    
  end
end
