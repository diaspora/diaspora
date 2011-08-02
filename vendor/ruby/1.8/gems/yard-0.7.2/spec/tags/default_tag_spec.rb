require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::Tags::DefaultTag do
  it "should create a tag with defaults" do
    o = YARD::Tags::DefaultTag.new('tagname', 'desc', ['types'], 'name', ['defaults'])
    o.defaults.should == ['defaults']
    o.tag_name.should == 'tagname'
    o.name.should == 'name'
    o.types.should == ['types']
  end
end