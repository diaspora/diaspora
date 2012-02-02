require 'spec_helper'

describe "places/edit" do
  before(:each) do
    @place = assign(:place, stub_model(Place,
      :title => "MyString",
      :lat => "9.99",
      :lng => "9.99",
      :description => "MyText",
      :image_url => "MyString",
      :image_height => 1,
      :image_width => 1
    ))
  end

  it "renders the edit place form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => places_path(@place), :method => "post" do
      assert_select "input#place_title", :name => "place[title]"
      assert_select "input#place_lat", :name => "place[lat]"
      assert_select "input#place_lng", :name => "place[lng]"
      assert_select "textarea#place_description", :name => "place[description]"
      assert_select "input#place_image_url", :name => "place[image_url]"
      assert_select "input#place_image_height", :name => "place[image_height]"
      assert_select "input#place_image_width", :name => "place[image_width]"
    end
  end
end
