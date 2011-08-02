Feature: standalone

  require "rspec/mocks/standalone" to expose the mock framework
  outside the RSpec environment. This is especially useful for
  exploring rspec-mocks in irb.

  Scenario: method stub outside rspec
    Given a file named "example.rb" with:
      """
      require "rspec/mocks/standalone"

      greeter = double("greeter")
      greeter.stub(:say_hi) { "Hello!" }
      puts greeter.say_hi
      """
    When I run `ruby example.rb`
    Then the output should contain "Hello!"

  Scenario: message expectation outside rspec
    Given a file named "example.rb" with:
      """
      require "rspec/mocks/standalone"

      greeter = double("greeter")
      greeter.should_receive(:say_hi)

      RSpec::Mocks.verify
      """
    When I run `ruby example.rb`
    Then the output should contain "say_hi(any args) (RSpec::Mocks::MockExpectationError)"
    Then the output should contain "expected: 1 time"
    Then the output should contain "received: 0 times"
