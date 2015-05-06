require "spec_helper"

describe "ensure configuration effects" do
  it "sets the captcha length as required" do
    expect(SimpleCaptcha.length).to eq(AppConfig.settings.captcha.captcha_length.to_i)
  end
end
