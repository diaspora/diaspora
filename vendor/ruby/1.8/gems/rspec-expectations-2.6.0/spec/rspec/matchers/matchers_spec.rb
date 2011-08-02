require 'spec_helper'

module RSpec
  describe Matchers do

    let(:sample_matchers) do
      [:be,
       :be_close,
       :be_instance_of,
       :be_kind_of]
    end

    context "once required" do
      it "includes itself in Test::Unit::TestCase" do
        test_unit_case = Test::Unit::TestCase.allocate
        sample_matchers.each do |sample_matcher|
            test_unit_case.should respond_to(sample_matcher)
        end
      end

      it "includes itself in MiniTest::Unit::TestCase", :if => defined?(MiniTest) do
        minitest_case = MiniTest::Unit::TestCase.allocate
        sample_matchers.each do |sample_matcher|
            minitest_case.should respond_to(sample_matcher)
        end
      end

    end

  end
end
