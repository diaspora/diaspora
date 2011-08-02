require 'spec_helper'
require 'cucumber/ast'
require 'cucumber/step_mother'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module RbSupport
    describe RbStepDefinition do
      let(:user_interface) { double('user interface') }
      let(:support_code) { Cucumber::Runtime::SupportCode.new(user_interface) }
      let(:rb)      { support_code.load_programming_language('rb')}
      let(:dsl) do 
        rb
        Object.new.extend(Cucumber::RbSupport::RbDsl)
      end
      
      before do      
        rb.before(mock('scenario').as_null_object)

        $inside = nil
      end
      
      it "should allow calling of other steps" do
        dsl.Given /Outside/ do
          Given "Inside"
        end
        dsl.Given /Inside/ do
          $inside = true
        end

        support_code.step_match("Outside").invoke(nil)
        $inside.should == true
      end

      it "should allow calling of other steps with inline arg" do
        dsl.Given /Outside/ do
          Given "Inside", Cucumber::Ast::Table.new([['inside']])
        end
        dsl.Given /Inside/ do |table|
          $inside = table.raw[0][0]
        end

        support_code.step_match("Outside").invoke(nil)
        $inside.should == 'inside'
      end

      it "should raise Undefined when inside step is not defined" do
        dsl.Given /Outside/ do
          Given 'Inside'
        end

        lambda do
          support_code.step_match('Outside').invoke(nil)
        end.should raise_error(Cucumber::Undefined, 'Undefined step: "Inside"')
      end

      it "should allow forced pending" do
        dsl.Given /Outside/ do
          pending("Do me!")
        end

        lambda do
          support_code.step_match("Outside").invoke(nil)
        end.should raise_error(Cucumber::Pending, "Do me!")
      end

      it "should raise ArityMismatchError when the number of capture groups differs from the number of step arguments" do
        dsl.Given /No group: \w+/ do |arg|
        end

        lambda do
          support_code.step_match("No group: arg").invoke(nil)
        end.should raise_error(Cucumber::ArityMismatchError)
      end

      it "should allow puts" do
        user_interface.should_receive(:puts).with('wasup')
        dsl.Given /Loud/ do
          puts 'wasup'
        end
        
        support_code.step_match("Loud").invoke(nil)
      end
      
      it "should recognize $arg style captures" do
        dsl.Given "capture this: $arg" do |arg|
          arg.should == 'this'
        end

       support_code.step_match('capture this: this').invoke(nil)
      end

      it "should have a JSON representation of the signature" do
        RbStepDefinition.new(rb, /I CAN HAZ (\d+) CUKES/i, lambda{}).to_hash.should == {'source' => "I CAN HAZ (\\d+) CUKES", 'flags' => 'i'}
      end
    end
  end
end
