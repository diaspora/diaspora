require "spec_helper"

describe "render_template" do
  include RSpec::Rails::Matchers::RenderTemplate

  it "uses failure message from render_template" do
    self.stub!(:assert_template).and_raise(
      Test::Unit::AssertionFailedError.new("this message"))
    response = ActionController::TestResponse.new
    expect do
      response.should render_template("destination")
    end.to raise_error("this message")
  end

  context "given a hash" do
    it "delegates to assert_template" do
      self.should_receive(:assert_template).with({:this => "hash"}, "this message")
      "response".should render_template({:this => "hash"}, "this message")
    end
  end

  context "given a string" do
    it "delegates to assert_template" do
      self.should_receive(:assert_template).with("this string", "this message")
      "response".should render_template("this string", "this message")
    end
  end

  context "given a symbol" do
    it "converts to_s and delegates to assert_template" do
      self.should_receive(:assert_template).with("template_name", "this message")
      "response".should render_template(:template_name, "this message")
    end
  end
end

