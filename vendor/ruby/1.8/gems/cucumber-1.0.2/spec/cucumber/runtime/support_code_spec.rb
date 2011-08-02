require 'spec_helper'

module Cucumber
  describe Runtime::SupportCode do
    let(:user_interface) { double('user interface') }
    subject { Runtime::SupportCode.new(user_interface, options) }
    let(:options)     { {} }
    let(:dsl) do
      @rb = subject.load_programming_language('rb')
      Object.new.extend(RbSupport::RbDsl)
    end

    it "should format step names" do
      dsl.Given(/it (.*) in (.*)/) { |what, month| }
      dsl.Given(/nope something else/) { |what, month| }

      format = subject.step_match("it snows in april").format_args("[%s]")
      format.should == "it [snows] in [april]"
    end
    
    describe "resolving step defintion matches" do

      it "should raise Ambiguous error with guess hint when multiple step definitions match" do
        expected_error = %{Ambiguous match of "Three blind mice":

spec/cucumber/runtime/support_code_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/runtime/support_code_spec.rb:\\d+:in `/Three blind (.*)/'

You can run again with --guess to make Cucumber be more smart about it
}
        dsl.Given(/Three (.*) mice/) {|disability|}
        dsl.Given(/Three blind (.*)/) {|animal|}

        lambda do
          subject.step_match("Three blind mice")
        end.should raise_error(Ambiguous, /#{expected_error}/)
      end

      describe "when --guess is used" do
        let(:options) { {:guess => true} }

        it "should not show --guess hint" do
        expected_error = %{Ambiguous match of "Three cute mice":

spec/cucumber/runtime/support_code_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/runtime/support_code_spec.rb:\\d+:in `/Three cute (.*)/'

}
          dsl.Given(/Three (.*) mice/) {|disability|}
          dsl.Given(/Three cute (.*)/) {|animal|}

          lambda do
            subject.step_match("Three cute mice")
          end.should raise_error(Ambiguous, /#{expected_error}/)
        end

        it "should not raise Ambiguous error when multiple step definitions match" do
          dsl.Given(/Three (.*) mice/) {|disability|}
          dsl.Given(/Three (.*)/) {|animal|}

          lambda do
            subject.step_match("Three blind mice")
          end.should_not raise_error
        end

        it "should not raise NoMethodError when guessing from multiple step definitions with nil fields" do
          dsl.Given(/Three (.*) mice( cannot find food)?/) {|disability, is_disastrous|}
          dsl.Given(/Three (.*)?/) {|animal|}

          lambda do
            subject.step_match("Three blind mice")
          end.should_not raise_error
        end

        it "should pick right step definition when an equal number of capture groups" do
          right = dsl.Given(/Three (.*) mice/) {|disability|}
          wrong = dsl.Given(/Three (.*)/) {|animal|}

          subject.step_match("Three blind mice").step_definition.should == right
        end

        it "should pick right step definition when an unequal number of capture groups" do
          right = dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
          wrong = dsl.Given(/Three (.*)/) {|animal|}

          subject.step_match("Three blind mice ran far").step_definition.should == right
        end

        it "should pick most specific step definition when an unequal number of capture groups" do
          general       = dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
          specific      = dsl.Given(/Three blind mice ran far/) do; end
          more_specific = dsl.Given(/^Three blind mice ran far$/) do; end

          subject.step_match("Three blind mice ran far").step_definition.should == more_specific
        end
      end

      it "should raise Undefined error when no step definitions match" do
        lambda do
          subject.step_match("Three blind mice")
        end.should raise_error(Undefined)
      end

      # http://railsforum.com/viewtopic.php?pid=93881
      it "should not raise Redundant unless it's really redundant" do
        dsl.Given(/^(.*) (.*) user named '(.*)'$/) {|a,b,c|}
        dsl.Given(/^there is no (.*) user named '(.*)'$/) {|a,b|}
      end
    end

  end
end