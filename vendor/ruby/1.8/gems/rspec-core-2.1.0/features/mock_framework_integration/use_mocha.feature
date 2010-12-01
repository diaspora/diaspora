Feature: mock with mocha

  As an RSpec user who likes to mock
  I want to be able to use mocha

  Scenario: Mock with mocha
    Given a file named "mocha_example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.mock_framework = :mocha
      end

      describe "plugging in mocha" do
        it "allows mocha to be used" do
          target = Object.new
          target.expects(:foo).once
          target.foo
        end
      end
      """
    When I run "rspec ./mocha_example_spec.rb"
    Then the output should contain "1 example, 0 failures" 
    And the exit status should be 0
