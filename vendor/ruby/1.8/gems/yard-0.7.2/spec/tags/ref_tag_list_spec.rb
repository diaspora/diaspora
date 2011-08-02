require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::Tags::RefTagList do
  before { YARD::Registry.clear }
  
  it "should accept symbol or string as owner's path and convert it into a proxy" do
    t = Tags::RefTagList.new('author', :String)
    t.owner.should == P(:String)
  end
  
  it "should accept proxy object as owner" do
    t = Tags::RefTagList.new('author', P(:String))
    t.owner.should == P(:String)
  end
  
  it "should return tags from a proxy object" do
    o = CodeObjects::ClassObject.new(:root, :String)
    t = Tags::Tag.new(:author, 'foo')
    o.docstring.add_tag(t)
  
    ref = Tags::RefTagList.new('author', :String)
    ref.tags.should == [t]
    ref.tags.first.text.should == 'foo'
  end
  
  it "should return named tags from a proxy object" do
    o = CodeObjects::ClassObject.new(:root, :String)
    p1 = Tags::Tag.new(:param, 'bar1', nil, 'foo')
    p2 = Tags::Tag.new(:param, 'bar2', nil, 'foo')
    p3 = Tags::Tag.new(:param, 'bar3', nil, 'bar')
    t1 = Tags::Tag.new(:return, 'blah')
    o.docstring.add_tag(p1, t1, p2, p3)
  
    ref = Tags::RefTagList.new('param', :String, 'foo')
    ref.tags.should == [p1, p2]
    ref.tags.first.text.should == 'bar1'
  end
  
  it "all tags should respond to #owner and be a RefTag" do
    o = CodeObjects::ClassObject.new(:root, :String)
    p1 = Tags::Tag.new(:param, 'bar1', nil, 'foo')
    p2 = Tags::Tag.new(:param, 'bar2', nil, 'foo')
    p3 = Tags::Tag.new(:param, 'bar3', nil, 'bar')
    t1 = Tags::Tag.new(:return, 'blah')
    o.docstring.add_tag(p1, t1, p2, p3)
  
    ref = Tags::RefTagList.new('param', :String)
    ref.tags.each do |t|
      t.should be_kind_of(Tags::RefTag)
      t.owner.should == o
    end
  end
end