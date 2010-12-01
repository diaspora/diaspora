require "spec_helper"

describe RSpec::Rails::TestUnitAssertionAdapter do
  include RSpec::Rails::TestUnitAssertionAdapter

  Test::Unit::Assertions.public_instance_methods.select{|m| m.to_s =~ /^(assert|flunk)/}.each do |m|
    if m.to_s == "assert_equal"
      it "exposes #{m} to host examples" do
        assert_equal 3,3
        expect do
          assert_equal 3,4
        end.to raise_error(ActiveSupport::TestCase::Assertion)
      end
    else
      it "exposes #{m} to host examples" do
        methods.should include(m)
      end
    end
  end

  it "does not expose internal methods of MiniTest" do
    methods.should_not include("_assertions")
  end

  it "does not expose MiniTest's message method" do
    methods.should_not include("message")
  end
end
