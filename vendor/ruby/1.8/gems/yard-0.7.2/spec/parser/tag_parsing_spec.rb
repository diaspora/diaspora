require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe YARD::Parser, "tag handling" do
  before { parse_file :tag_handler_001, __FILE__ }
  
  it "should know the list of all available tags" do
    P("Foo#foo").tags.should include(P("Foo#foo").tag(:api))
  end
  
  it "should know the text of tags on a method" do
    P("Foo#foo").tag(:api).text.should == "public"
  end
  
  it "should return true when asked whether a tag exists" do
    P("Foo#foo").has_tag?(:api).should == true
  end
  
end
