module Mocha
  
  module ParameterMatchers
    
    class Base 
      
      def to_matcher # :nodoc:
        self
      end
      
      # :call-seq: &(matcher) -> parameter_matcher
      #
      # A short hand way of specifying multiple matchers that should
      # all match.
      #
      # Returns a new +AllOf+ parameter matcher combining the
      # given matcher and the receiver.
      #
      # The following statements are equivalent:
      #   object = mock()
      #   object.expects(:run).with(all_of(has_key(:foo), has_key(:bar)))
      #   object.run(:foo => 'foovalue', :bar => 'barvalue')
      #
      #   # with the shorthand
      #   object.expects(:run).with(has_key(:foo) & has_key(:bar))
      #   object.run(:foo => 'foovalue', :bar => 'barvalue)
      def &(matcher)
        AllOf.new(self, matcher)
      end
      
      # :call-seq: |(matcher) -> parameter_matcher
      #
      # A short hand way of specifying multiple matchers, only at least
      # one of which should pass.
      #
      # Returns a new +AnyOf+ parameter matcher combining the
      # given matcher and the receiver.
      #
      # The following statements are equivalent:
      #   object = mock()
      #   object.expects(:run).with(any_of(has_key(:foo), has_key(:bar)))
      #   object.run(:foo => 'foovalue')
      #
      #   # with the shorthand
      #   object.expects(:run).with(has_key(:foo) | has_key(:bar))
      #   object.run(:foo => 'foovalue')
      #
      # This shorthand will not work with an implicit equals match. Instead,
      # an explicit equals matcher should be used:
      #
      #   object.expects(:run).with(equals(1) | equals(2))
      #   object.run(1) # passes
      #   object.run(2) # passes
      #   object.run(3) # fails
      def |(matcher)
        AnyOf.new(self, matcher)
      end
      
    end
    
  end
  
end
