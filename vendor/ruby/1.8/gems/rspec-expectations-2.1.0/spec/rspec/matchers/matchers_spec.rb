require 'spec_helper'

module Test
  module Unit
    class TestCase
    end
  end
end

module MiniTest
  module Unit
    class TestCase
    end
  end
end

module RSpec
  describe Matchers do

    let(:sample_matchers) do
      [:be,
       :be_close,
       :be_instance_of,
       :be_kind_of]
    end

    context "once required" do

      before(:all) do
        path = File.expand_path("../../../../#{path}", __FILE__)
        load File.join(path, 'lib/rspec/matchers.rb')
      end

      it "includes itself in Test::Unit::TestCase" do
        test_unit_case = Test::Unit::TestCase.new
        sample_matchers.each do |sample_matcher|
            test_unit_case.should respond_to(sample_matcher)
        end
      end

      it "includes itself in MiniTest::Unit::TestCase" do
        minitest_case = MiniTest::Unit::TestCase.new
        sample_matchers.each do |sample_matcher|
            minitest_case.should respond_to(sample_matcher)
        end
      end

    end

  end
end
