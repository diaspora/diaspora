require "spec_helper"
require "active_support/test_case"

describe "redirect_to" do
  include RSpec::Rails::Matchers::RedirectTo

  let(:response) { ActionController::TestResponse.new }

  it "delegates to assert_redirected_to" do
    self.should_receive(:assert_redirected_to).with("destination")
    "response".should redirect_to("destination")
  end

  context "with should" do
    context "when assert_redirected_to passes" do
      it "passes" do
        self.stub!(:assert_redirected_to)
        expect do
          response.should redirect_to("destination")
        end.to_not raise_exception
      end
    end

    context "when assert_redirected_to fails" do
      it "uses failure message from assert_redirected_to" do
        self.stub!(:assert_redirected_to) do
          raise ActiveSupport::TestCase::Assertion.new("this message")
        end
        expect do
          response.should redirect_to("destination")
        end.to raise_error("this message")
      end
    end

    context "when fails due to some other exception" do
      it "raises that exception" do
        self.stub!(:assert_redirected_to) do
          raise "oops"
        end
        expect do
          response.should redirect_to("destination")
        end.to raise_exception("oops")
      end
    end
  end

  context "with should_not" do
    context "when assert_redirected_to fails" do
      it "passes" do
        self.stub!(:assert_redirected_to) do
          raise ActiveSupport::TestCase::Assertion.new("this message")
        end
        expect do
          response.should_not redirect_to("destination")
        end.to_not raise_exception
      end
    end

    context "when assert_redirected_to passes" do
      it "fails with custom failure message" do
        self.stub!(:assert_redirected_to)
        expect do
          response.should_not redirect_to("destination")
        end.to raise_error(/expected not to redirect to \"destination\", but did/)
      end
    end

    context "when fails due to some other exception" do
      it "raises that exception" do
        self.stub!(:assert_redirected_to) do
          raise "oops"
        end
        expect do
          response.should_not redirect_to("destination")
        end.to raise_exception("oops")
      end
    end
  end
end
