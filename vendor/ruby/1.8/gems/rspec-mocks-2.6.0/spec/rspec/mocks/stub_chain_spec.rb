require 'spec_helper'

module RSpec
  module Mocks
    describe "A chained method stub" do
      subject { Object.new }

      context "with one method in chain" do
        context "using and_return" do
          it "returns expected value from chaining only one method call" do
            subject.stub_chain(:msg1).and_return(:return_value)
            subject.msg1.should equal(:return_value)
          end
        end

        context "using a block" do
          it "returns the correct value" do
            subject.stub_chain(:msg1) { :return_value }
            subject.msg1.should equal(:return_value)
          end
        end

        context "using a hash" do
          it "returns the value of the key/value pair" do
            subject.stub_chain(:msg1 => :return_value)
            subject.msg1.should equal(:return_value)
          end
        end
      end

      context "with two methods in chain" do
        context "using and_return" do
          it "returns expected value from chaining two method calls" do
            subject.stub_chain(:msg1, :msg2).and_return(:return_value)
            subject.msg1.msg2.should equal(:return_value)
          end
        end

        context "using a block" do
          it "returns the correct value" do
            subject.stub_chain(:msg1, :msg2) { :return_value }
            subject.msg1.msg2.should equal(:return_value)
          end
        end

        context "using a hash" do
          it "returns the value of the key/value pair" do
            subject.stub_chain(:msg1, :msg2 => :return_value)
            subject.msg1.msg2.should equal(:return_value)
          end
        end
      end

      context "with four methods in chain" do
        context "using and_return" do
          it "returns expected value from chaining two method calls" do
            subject.stub_chain(:msg1, :msg2, :msg3, :msg4).and_return(:return_value)
            subject.msg1.msg2.msg3.msg4.should equal(:return_value)
          end
        end

        context "using a block" do
          it "returns the correct value" do
            subject.stub_chain(:msg1, :msg2, :msg3, :msg4) { :return_value }
            subject.msg1.msg2.msg3.msg4.should equal(:return_value)
          end
        end

        context "using a hash" do
          it "returns the value of the key/value pair" do
            subject.stub_chain(:msg1, :msg2, :msg3, :msg4 => :return_value)
            subject.msg1.msg2.msg3.msg4.should equal(:return_value)
          end
        end

        context "using a hash with a string key" do
          it "returns the value of the key/value pair" do
            subject.stub_chain("msg1.msg2.msg3.msg4" => :return_value)
            subject.msg1.msg2.msg3.msg4.should equal(:return_value)
          end
        end
      end

      it "returns expected value from chaining four method calls" do
        subject.stub_chain(:msg1, :msg2, :msg3, :msg4).and_return(:return_value)
        subject.msg1.msg2.msg3.msg4.should equal(:return_value)
      end

      context "with messages shared across multiple chains" do
        context "using and_return" do
          context "starting with the same message" do
            it "returns expected value" do
              subject.stub_chain(:msg1, :msg2, :msg3).and_return(:first)
              subject.stub_chain(:msg1, :msg2, :msg4).and_return(:second)

              subject.msg1.msg2.msg3.should equal(:first)
              subject.msg1.msg2.msg4.should equal(:second)
            end
          end

          context "starting with the different messages" do
            it "returns expected value" do
              subject.stub_chain(:msg1, :msg2, :msg3).and_return(:first)
              subject.stub_chain(:msg4, :msg2, :msg3).and_return(:second)

              subject.msg1.msg2.msg3.should equal(:first)
              subject.msg4.msg2.msg3.should equal(:second)
            end
          end
        end

        context "using => value" do
          context "starting with the same message" do
            it "returns expected value", :focus => true do
              subject.stub_chain(:msg1, :msg2, :msg3 => :first)
              subject.stub_chain(:msg1, :msg2, :msg4 => :second)

              subject.msg1.msg2.msg3.should equal(:first)
              subject.msg1.msg2.msg4.should equal(:second)
            end
          end

          context "starting with different messages" do
            it "returns expected value", :focus => true do
              subject.stub_chain(:msg1, :msg2, :msg3 => :first)
              subject.stub_chain(:msg4, :msg2, :msg3 => :second)

              subject.msg1.msg2.msg3.should equal(:first)
              subject.msg4.msg2.msg3.should equal(:second)
            end
          end
        end
      end

      it "returns expected value when chain is a dot separated string, like stub_chain('msg1.msg2.msg3')" do
        subject.stub_chain("msg1.msg2.msg3").and_return(:return_value)
        subject.msg1.msg2.msg3.should equal(:return_value)
      end

      it "returns expected value from two chains with shared messages at the beginning" do
        subject.stub_chain(:msg1, :msg2, :msg3, :msg4).and_return(:first)
        subject.stub_chain(:msg1, :msg2, :msg3, :msg5).and_return(:second)

        subject.msg1.msg2.msg3.msg4.should equal(:first)
        subject.msg1.msg2.msg3.msg5.should equal(:second)
      end
    end
  end
end
