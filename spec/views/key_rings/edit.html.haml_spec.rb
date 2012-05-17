require 'spec_helper'

describe "key_rings/edit" do
  before(:each) do
    @key_ring = assign(:key_ring, stub_model(KeyRing))
  end

  it "renders the edit key_ring form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => key_rings_path(@key_ring), :method => "post" do
    end
  end
end
