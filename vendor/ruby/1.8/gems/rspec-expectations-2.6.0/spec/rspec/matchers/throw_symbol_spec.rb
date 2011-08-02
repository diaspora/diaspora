require 'spec_helper'

module RSpec
  module Matchers
    describe ThrowSymbol do
      describe "with no args" do
        before(:each) { @matcher = throw_symbol }
      
        it "matches if any Symbol is thrown" do
          @matcher.matches?(lambda{ throw :sym }).should be_true
        end
        it "matches if any Symbol is thrown with an arg" do
          @matcher.matches?(lambda{ throw :sym, "argument" }).should be_true
        end
        it "does not match if no Symbol is thrown" do
          @matcher.matches?(lambda{ }).should be_false
        end
        it "provides a failure message" do
          @matcher.matches?(lambda{})
          @matcher.failure_message_for_should.should == "expected a Symbol to be thrown, got nothing"
        end
        it "provides a negative failure message" do
          @matcher.matches?(lambda{ throw :sym})
          @matcher.failure_message_for_should_not.should == "expected no Symbol to be thrown, got :sym"
        end
      end
          
      describe "with a symbol" do
        before(:each) { @matcher = throw_symbol(:sym) }
      
        it "matches if correct Symbol is thrown" do
          @matcher.matches?(lambda{ throw :sym }).should be_true
        end
        it "matches if correct Symbol is thrown with an arg" do
          @matcher.matches?(lambda{ throw :sym, "argument" }).should be_true
        end
        it "does not match if no Symbol is thrown" do
          @matcher.matches?(lambda{ }).should be_false
        end
        it "does not match if correct Symbol is thrown" do
          @matcher.matches?(lambda{ throw :other_sym }).should be_false
        end
        it "provides a failure message when no Symbol is thrown" do
          @matcher.matches?(lambda{})
          @matcher.failure_message_for_should.should == "expected :sym to be thrown, got nothing"
        end
        it "provides a failure message when wrong Symbol is thrown" do
          @matcher.matches?(lambda{ throw :other_sym })
          @matcher.failure_message_for_should.should == "expected :sym to be thrown, got :other_sym"
        end
        it "provides a negative failure message" do
          @matcher.matches?(lambda{ throw :sym })
          @matcher.failure_message_for_should_not.should == "expected :sym not to be thrown, got :sym"
        end
        it "only matches NameErrors raised by uncaught throws" do
          expect {
            @matcher.matches?(lambda{ sym }).should be_false
          }.to raise_error(NameError)
        end
      end

      describe "with a symbol and an arg" do
        before(:each) { @matcher = throw_symbol(:sym, "a") }
    
        it "matches if correct Symbol and args are thrown" do
          @matcher.matches?(lambda{ throw :sym, "a" }).should be_true
        end
        it "does not match if nothing is thrown" do
          @matcher.matches?(lambda{ }).should be_false
        end
        it "does not match if other Symbol is thrown" do
          @matcher.matches?(lambda{ throw :other_sym, "a" }).should be_false
        end
        it "does not match if no arg is thrown" do
          @matcher.matches?(lambda{ throw :sym }).should be_false
        end
        it "does not match if wrong arg is thrown" do
          @matcher.matches?(lambda{ throw :sym, "b" }).should be_false
        end
        it "provides a failure message when no Symbol is thrown" do
          @matcher.matches?(lambda{})
          @matcher.failure_message_for_should.should == %q[expected :sym with "a" to be thrown, got nothing]
        end
        it "provides a failure message when wrong Symbol is thrown" do
          @matcher.matches?(lambda{ throw :other_sym })
          @matcher.failure_message_for_should.should == %q[expected :sym with "a" to be thrown, got :other_sym]
        end
        it "provides a failure message when wrong arg is thrown" do
          @matcher.matches?(lambda{ throw :sym, "b" })
          @matcher.failure_message_for_should.should == %q[expected :sym with "a" to be thrown, got :sym with "b"]
        end
        it "provides a failure message when no arg is thrown" do
          @matcher.matches?(lambda{ throw :sym })
          @matcher.failure_message_for_should.should == %q[expected :sym with "a" to be thrown, got :sym with no argument]
        end
        it "provides a negative failure message" do
          @matcher.matches?(lambda{ throw :sym })
          @matcher.failure_message_for_should_not.should == %q[expected :sym with "a" not to be thrown, got :sym with no argument]
        end
        it "only matches NameErrors raised by uncaught throws" do
          expect {
            @matcher.matches?(lambda{ sym }).should be_false
          }.to raise_error(NameError)
        end
        it "raises other errors" do
          expect {
            @matcher.matches?(lambda { raise "Boom" })
          }.to raise_error(/Boom/)
        end
      end
    end
  end
end
