Feature: mock with flexmock

  As an RSpec user who likes to mock
  I want to be able to use flexmock

  Scenario: Mock with flexmock
    Given a file named "flexmock_example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.mock_framework = :flexmock
      end

      describe "plugging in flexmock" do
        it "allows flexmock to be used" do
          target = Object.new
          flexmock(target).should_receive(:foo).once
          target.foo
        end
      end
      """
    When I run "rspec ./flexmock_example_spec.rb"
    Then the output should contain "1 example, 0 failures" 
    And the exit status should be 0
