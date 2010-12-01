require "spec_helper"
require "action_controller/test_case"

describe "redirect_to" do
  include RSpec::Rails::Matchers::RedirectTo

  it "delegates to assert_redirected_to" do
    self.should_receive(:assert_redirected_to).with("destination")
    "response".should redirect_to("destination")
  end

  it "uses failure message from assert_redirected_to" do
    self.stub!(:assert_redirected_to).and_raise(
      Test::Unit::AssertionFailedError.new("this message"))
    response = ActionController::TestResponse.new
    expect do
      response.should redirect_to("destination")
    end.to raise_error("this message")
  end
end
