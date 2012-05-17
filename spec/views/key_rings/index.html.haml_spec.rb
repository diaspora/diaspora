require 'spec_helper'

describe "key_rings/index" do
  before(:each) do
    assign(:key_rings, [
      stub_model(KeyRing),
      stub_model(KeyRing)
    ])
  end

  it "renders a list of key_rings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
