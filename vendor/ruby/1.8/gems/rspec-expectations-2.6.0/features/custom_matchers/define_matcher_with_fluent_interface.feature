Feature: define matcher with fluent interface

  Use the chain() method to define matchers with a fluent interface.
  
  Scenario: chained method with argumetn
    Given a file named "between_spec.rb" with:
      """
      RSpec::Matchers.define :be_bigger_than do |first|
        match do |actual|
          (actual > first) && (actual < @second)
        end

        chain :but_smaller_than do |second|
          @second = second
        end
      end

      describe 5 do
        it { should be_bigger_than(4).but_smaller_than(6) }
      end
      """
    When I run `rspec between_spec.rb --format documentation`
    Then the output should contain "1 example, 0 failures"
    And  the output should contain "should be bigger than 4"
