require 'spec_helper'

describe "key_rings/new" do
  before(:each) do
    assign(:key_ring, stub_model(KeyRing).as_new_record)
  end

  it "renders new key_ring form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => key_rings_path, :method => "post" do
    end
  end
end
