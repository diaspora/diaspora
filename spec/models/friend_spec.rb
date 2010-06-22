require File.dirname(__FILE__) + '/../spec_helper'

describe Friend do

  it 'should require a diaspora username and diaspora url' do 
    n = Factory.build(:friend, :url => nil)
    n.valid?.should be false
    n.url = "http://max.com/"
    n.valid?.should be true
  end

  it 'should require a real name' do
    n = Factory.build(:friend, :real_name => nil)
    n.valid?.should be false
    n.real_name = "John Smith"
    n.valid?.should be true
  end


  it 'should validate its url' do
    friend = Factory.build(:friend)

    #urls changed valid
    friend.url = "google.com"
    friend.valid?.should == true 
    friend.url.should == "http://google.com/"

    friend.url = "www.google.com"
    friend.valid?.should == true
    friend.url.should == "http://www.google.com/"

    friend.url = "google.com/"
    friend.valid?.should == true
    friend.url.should == "http://google.com/"

    friend.url = "www.google.com/"
    friend.valid?.should == true
    friend.url.should == "http://www.google.com/"

    friend.url = "http://google.com"
    friend.valid?.should == true
    friend.url.should == "http://google.com/"

    friend.url = "http://www.google.com"
    friend.valid?.should == true

    #invalid urls
    friend.url = "zsdvzxdg"
    friend.valid?.should == false
    friend.url = "sdfasfa.c"
    friend.valid?.should == false
    friend.url = "http://.com/"
    friend.valid?.should == false
    friend.url = "http://www..com/"
    friend.valid?.should == false
    friend.url = "http:/www.asodij.com/"
    friend.valid?.should == false
    friend.url = "https:/www.asodij.com/"
    friend.valid?.should == false
    friend.url = "http:///www.asodij.com/"
    friend.valid?.should == false
  end

   describe "XML" do
    before do
      @f = Factory.build(:friend)
      @xml = "<friend>\n  <username>#{@f.username}</username>\n  <url>#{@f.url}</url>\n  <real_name>#{@f.real_name}</real_name>\n</friend>" 
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
