Feature: Expect a message

  Use should_receive() to set an expectation that a receiver should receive a
  message before the example is completed.

  Scenario: expect a message
    Given a file named "spec/account_spec.rb" with:
      """
      require "account"

      describe Account do
        context "when closed" do
          it "logs an account closed message" do
            logger = double("logger")
            account = Account.new
            account.logger = logger

            logger.should_receive(:account_closed)

            account.close
          end
        end
      end
      """
    And a file named "lib/account.rb" with:
      """
      class Account
        attr_accessor :logger

        def close
          logger.account_closed
        end
      end
      """
    When I run "rspec spec/account_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: expect a message with an argument
    Given a file named "spec/account_spec.rb" with:
      """
      require "account"

      describe Account do
        context "when closed" do
          it "logs an account closed message" do
            logger = double("logger")
            account = Account.new
            account.logger = logger

            logger.should_receive(:account_closed).with(account)

            account.close
          end
        end
      end
      """
    And a file named "lib/account.rb" with:
      """
      class Account
        attr_accessor :logger

        def close
          logger.account_closed(self)
        end
      end
      """
    When I run "rspec spec/account_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: provide a return value
    Given a file named "message_expectation_spec.rb" with:
      """
      describe "a message expectation" do
        context "with a return value" do
          context "specified in a block" do
            it "returns the specified value" do
              receiver = double("receiver")
              receiver.should_receive(:message) { :return_value }
              receiver.message.should eq(:return_value)
            end
          end

          context "specified with and_return" do
            it "returns the specified value" do
              receiver = double("receiver")
              receiver.should_receive(:message).and_return(:return_value)
              receiver.message.should eq(:return_value)
            end
          end
        end
      end
      """
    When I run "rspec message_expectation_spec.rb"
    Then the output should contain "2 examples, 0 failures"
