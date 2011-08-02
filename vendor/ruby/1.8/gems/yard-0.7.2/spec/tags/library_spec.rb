require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::Tags::Library do
  def tag(docstring)
    Docstring.new(docstring).tags.first
  end
  
  describe '#see_tag' do
    it "should take a URL" do
      tag("@see http://example.com").name.should == "http://example.com"
    end
    
    it "should take an object path" do
      tag("@see String#reverse").name.should == "String#reverse"
    end
    
    it "should take a description after the url/object" do
      tag = tag("@see http://example.com An Example Site")
      tag.name.should == "http://example.com"
      tag.text.should == "An Example Site"
    end
  end
end