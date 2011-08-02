Feature: text formatter

  In order to easily see the result of running my specs
  As an RSpec user
  I want clear, concise, well-formatted output

  Scenario: Backtrace formatting for failing specs in multiple files
    Given a file named "string_spec.rb" with:
      """
      describe String do
        it "has a failing example" do
          "foo".reverse.should == "ofo"
        end
      end
      """
    And a file named "integer_spec.rb" with:
      """
      require 'rspec/autorun'

      describe Integer do
        it "has a failing example" do
          (7 + 5).should == 11
        end
      end
      """
    When I run `ruby ./integer_spec.rb ./string_spec.rb`
    Then the backtrace-normalized output should contain:
      """
      Failures:

        1) Integer has a failing example
           Failure/Error: (7 + 5).should == 11
             expected: 11
                  got: 12 (using ==)
           # ./integer_spec.rb:5

        2) String has a failing example
           Failure/Error: "foo".reverse.should == "ofo"
             expected: "ofo"
                  got: "oof" (using ==)
           # ./string_spec.rb:3
      """

