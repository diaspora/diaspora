Feature: mock with rr

  As an RSpec user who likes to mock
  I want to be able to use rr

  Scenario: Mock with rr
    Given a file named "rr_example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.mock_framework = :rr
      end

      describe "plugging in rr" do
        it "allows rr to be used" do
          target = Object.new
          mock(target).foo
          target.foo
        end
      end
      """
    When I run "rspec ./rr_example_spec.rb"
    Then the output should contain "1 example, 0 failures" 
    And the exit status should be 0
