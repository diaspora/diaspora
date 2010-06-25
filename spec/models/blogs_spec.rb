require File.dirname(__FILE__) + '/../spec_helper'

describe Blog do
  before do
    Factory.create(:user, :email => "bob@aol.com")
  end

  it "should have a title and body" do    
    n = Blog.new
    n.valid?.should be false
    n.title = "jimmy"
    n.valid?.should be false
    n.body = "wales"
    n.valid?.should be true
  end
  
  it "should add an owner if none is present" do
    b = Factory.create(:blog)
    b.owner.should == "bob@aol.com"
  end
  
  describe "newest" do
    before do
      (2..4).each { Factory.create(:blog, :owner => "some@dudes.com") }
      (5..8).each { Factory.create(:blog) }
      (9..11).each { Factory.create(:blog, :owner => "other@dudes.com") }
    end
  
    it "should give the most recent blog title and body from owner" do
      blog = Blog.my_newest
      blog.title.should == "bobby's 8 penguins"
      blog.body.should == "jimmy's huge 8 whales"
    end
    
    it "should give the most recent blog body for a given email" do
      blog = Blog.newest("some@dudes.com")
      blog.title.should == "bobby's 14 penguins"
      blog.body.should == "jimmy's huge 14 whales"
    end
  end
  
  describe "XML" do
    it 'should serialize to XML' do
      body = Factory.create(:blog, :title => "yessir", :body => "penguins")
      body.to_xml.to_s.should include "<title>yessir</title>"
      body.to_xml.to_s.should include "<body>penguins</body>"
    end
  
    it 'should marshal serialized XML to object' do       
      xml = "<blog>\n  <title>yessir</title>\n  <body>I hate WALRUSES!</body>\n</blog>" 
      parsed = Blog.from_xml(xml)
      parsed.body.should == "I hate WALRUSES!"
    end
  end
end
