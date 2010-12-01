Feature: Predicate matchers

  Ruby objects commonly provide predicate methods:

    * 7.zero?                  # => false
    * 0.zero?                  # => true
    * [1].empty?               # => false
    * [].empty?                # => true
    * { :a => 5 }.has_key?(:b) # => false
    * { :b => 5 }.has_key?(:b) # => true

  You could use a basic equality matcher to set expectations on these:

    7.zero?.should == true # fails with "expected true, got false (using ==)"

  ...but RSpec provides dynamic predicate matchers that are more readable and
  provide better failure output.

  For any predicate method, RSpec gives you a corresponding matcher.  Simply
  prefix the method with "be_" and remove the question mark.  Examples:

    * 7.should_not be_zero       # calls 7.zero?
    * [].should be_empty         # calls [].empty?
    * x.should be_multiple_of(3) # calls x.multiple_of?(3)

  Alternately, for a predicate method that begins with "has_" like Hash#has_key?,
  RSpec allows you to use an alternate form since "be_has_key" makes no sense.

    * hash.should have_key(:foo)       # calls hash.has_key?(:foo)
    * array.should_not have_odd_values # calls array.has_odd_values?

  In either case, RSpec provides nice, clear error messages, such as:

    expected zero? to return true, got false

  Any arguments passed to the matcher will be passed on to the predicate method.

  Scenario: should be_zero (based on Fixnum#zero?)
    Given a file named "should_be_zero_spec.rb" with:
      """
      describe 0 do
        it { should be_zero }
      end

      describe 7 do
        it { should be_zero } # deliberate failure
      end
      """
    When I run "rspec should_be_zero_spec.rb"
    Then the output should contain "2 examples, 1 failure"
     And the output should contain "expected zero? to return true, got false"

  Scenario: should_not be_empty (based on Array#empty?)
    Given a file named "should_not_be_empty_spec.rb" with:
      """
      describe [1, 2, 3] do
        it { should_not be_empty }
      end

      describe [] do
        it { should_not be_empty } # deliberate failure
      end
      """
    When I run "rspec should_not_be_empty_spec.rb"
    Then the output should contain "2 examples, 1 failure"
     And the output should contain "expected empty? to return false, got true"

   Scenario: should have_key (based on Hash#has_key?)
    Given a file named "should_have_key_spec.rb" with:
      """
      describe Hash do
        subject { { :foo => 7 } }
        it { should have_key(:foo) }
        it { should have_key(:bar) } # deliberate failure
      end
      """
    When I run "rspec should_have_key_spec.rb"
    Then the output should contain "2 examples, 1 failure"
     And the output should contain "expected #has_key?(:bar) to return true, got false"

   Scenario: should_not have_all_string_keys (based on custom #has_all_string_keys? method)
     Given a file named "should_not_have_all_string_keys_spec.rb" with:
       """
       class Hash
         def has_all_string_keys?
           keys.all? { |k| String === k }
         end
       end

       describe Hash do
         context 'with symbol keys' do
           subject { { :foo => 7, :bar => 5 } }
           it { should_not have_all_string_keys }
         end

         context 'with string keys' do
           subject { { 'foo' => 7, 'bar' => 5 } }
           it { should_not have_all_string_keys } # deliberate failure
         end
       end
       """
     When I run "rspec should_not_have_all_string_keys_spec.rb"
     Then the output should contain "2 examples, 1 failure"
      And the output should contain "expected #has_all_string_keys?(nil) to return false, got true"

   Scenario: matcher arguments are passed on to the predicate method
     Given a file named "predicate_matcher_argument_spec.rb" with:
       """
       class Fixnum
         def multiple_of?(x)
           (self % x).zero?
         end
       end

       describe 12 do
         it { should be_multiple_of(3) }
         it { should_not be_multiple_of(7) }

         # deliberate failures
         it { should_not be_multiple_of(4) }
         it { should be_multiple_of(5) }
       end
       """
     When I run "rspec predicate_matcher_argument_spec.rb"
     Then the output should contain "4 examples, 2 failures"
      And the output should contain "expected multiple_of?(4) to return false, got true"
      And the output should contain "expected multiple_of?(5) to return true, got false"

