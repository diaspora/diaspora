require File.dirname(__FILE__) + '/../spec_helper'

describe Friend do
  it 'should have a diaspora username and diaspora url' do 
    n = Factory.build(:friend, :url => nil)
    n.valid?.should be false
    n.url = "http://max.com/"
    n.valid?.should be true
  end

   describe "XML" do
    before do
      @f = Factory.build(:friend)
      @xml = "<friend>\n  <username>#{@f.username}</username>\n  <url>#{@f.url}</url>\n</friend>" 
    end
      
    it 'should serialize to XML' do
      @f.to_xml.to_s.should == @xml
    end
  
    it 'should marshal serialized XML to object' do       
      parsed = Friend.from_xml(@xml)
      parsed.username.should == @f.username
      parsed.url.should == @f.url
      parsed.valid?.should be_true
    end
  end

end
