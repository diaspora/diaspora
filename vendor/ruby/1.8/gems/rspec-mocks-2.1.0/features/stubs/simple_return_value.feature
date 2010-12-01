Feature: Stub with simple return value

  Use the stub() method on a test double or a real object to tell the object to
  return a value (or values) in response to a given message. If the message is
  never received, nothing happens.

  Scenario: simple stub with no return value
    Given a file named "example_spec.rb" with:
      """
      describe "a simple stub with no return value specified" do
        let(:receiver) { double("receiver") }

        it "returns nil" do
          receiver.stub(:message)
          receiver.message.should be(nil)
        end

        it "quietly carries on when not called" do
          receiver.stub(:message)
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain "0 failures"

  Scenario: single return value
    Given a file named "example_spec.rb" with:
      """
      describe "a simple stub with a return value" do
        context "specified in a block" do
          it "returns the specified value" do
            receiver = double("receiver")
            receiver.stub(:message) { :return_value }
            receiver.message.should eq(:return_value)
          end
        end

        context "specified in the double declaration" do
          it "returns the specified value" do
            receiver = double("receiver", :message => :return_value)
            receiver.message.should eq(:return_value)
          end
        end

        context "specified with and_return" do
          it "returns the specified value" do
            receiver = double("receiver")
            receiver.stub(:message).and_return(:return_value)
            receiver.message.should eq(:return_value)
          end
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain "0 failures"
