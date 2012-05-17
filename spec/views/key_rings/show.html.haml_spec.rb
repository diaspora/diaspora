require 'spec_helper'

describe "key_rings/show" do
  before(:each) do
    @key_ring = assign(:key_ring, stub_model(KeyRing))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
