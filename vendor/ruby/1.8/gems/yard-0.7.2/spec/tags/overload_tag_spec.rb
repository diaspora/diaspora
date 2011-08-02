require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::Tags::OverloadTag do
  before do
    @tag = Tags::OverloadTag.new(:overload, <<-'eof')
      def bar(a, b = 1, &block)
        Hello world
        @param a [String]
        @return [String]
    eof
  end
  
  it "should parse the first line as a method signature" do
    @tag.signature.should == "def bar(a, b = 1, &block)"
    @tag.parameters.should == [[:a, nil], [:b, "1"], [:"&block", nil]]
  end
  
  it "should parse the rest of the text as a new Docstring" do
    @tag.docstring.should be_instance_of(Docstring)
    @tag.docstring.should == "Hello world"
  end
  
  it "should set Docstring's object after #object= is called" do
    m = mock(:object)
    @tag.object = m
    @tag.docstring.object.should == m
  end
  
  it "should respond to #tag, #tags and #has_tag?" do
    @tag.object = mock(:object)
    @tag.tags.size.should == 2
    @tag.tag(:param).name.should == "a"
    @tag.has_tag?(:return).should == true
  end
  
  it "should not be a CodeObjects::Base when not hooked up to an object" do
    @tag.object = nil
    @tag.is_a?(CodeObjects::Base).should == false
  end
  
  it "should be a CodeObjects::Base when hooked up to an object" do
    @tag.object = mock(:object)
    @tag.object.should_receive(:is_a?).at_least(3).times.with(CodeObjects::Base).and_return(true)
    @tag.is_a?(CodeObjects::Base).should == true
    @tag.kind_of?(CodeObjects::Base).should == true
    (CodeObjects::Base === @tag).should == true
  end

  it "should not parse 'def' out of method name" do
    tag = Tags::OverloadTag.new(:overload, "default")
    tag.signature.should == "default"
  end
end