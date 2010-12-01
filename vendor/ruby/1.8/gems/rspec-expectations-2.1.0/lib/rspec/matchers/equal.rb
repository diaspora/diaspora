module RSpec
  module Matchers

    # :call-seq:
    #   should equal(expected)
    #   should_not equal(expected)
    #
    # Passes if actual and expected are the same object (object identity).
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more information about equality in Ruby.
    #
    # == Examples
    #
    #   5.should equal(5) #Fixnums are equal
    #   "5".should_not equal("5") #Strings that look the same are not the same object
    def equal(expected)
      Matcher.new :equal, expected do |_expected_|
        match do |actual|
          actual.equal?(_expected_)
        end
        
        def inspect_object(o)
          "#<#{o.class}:#{o.object_id}> => #{o.inspect}"
        end
        
        failure_message_for_should do |actual|
          <<-MESSAGE

expected #{inspect_object(_expected_)}
     got #{inspect_object(actual)}

Compared using equal?, which compares object identity,
but expected and actual are not the same object. Use
'actual.should == expected' if you don't care about
object identity in this example.

MESSAGE
        end

        failure_message_for_should_not do |actual|
          <<-MESSAGE

expected not #{inspect_object(actual)}
         got #{inspect_object(_expected_)}

Compared using equal?, which compares object identity.

MESSAGE
        end
      end
    end
  end
end
