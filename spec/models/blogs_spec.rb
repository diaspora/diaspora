require File.dirname(__FILE__) + '/../spec_helper'

describe Blog do
  it "should have a title and body" do    
    n = Blog.new
    n.valid?.should be false
    n.title = "jimmy"
    n.valid?.should be false
    n.body = "wales"
    n.valid?.should be true
  end
  
  it "should add an owner if none is present" do
    User.create(:email => "bob@aol.com", :password => "big bux")
    n = Blog.create(:title => "kittens", :body => "puppies!")
    n.owner.should == "bob@aol.com"
  end
  
  
  describe "newest" do
    before do
      User.create(:email => "bob@aol.com", :password => "diggity")
      Blog.create(:title => "bone dawg", :body => "wale for jimmy", :owner => "xzibit@dawgz.com")
      Blog.create(:title => "dawg bone", :body => "jimmy wales")
      Blog.create(:title => "bone dawg", :body => "jimmy your wales", :owner => "some@dudes.com")  
      Blog.create(:title => "dawg bone", :body => "lions", :owner => "xzibit@dawgz.com")
      Blog.create(:title => "bone dawg", :body => "bears")
      Blog.create(:title => "dawg bone", :body => "sharks", :owner => "some@dudes.com")
      Blog.create(:title => "bone dawg", :body => "roar")
    end
  
    it "should give the most recent blog title and body from owner" do
      blog = Blog.my_newest
      blog.title.should == "bone dawg"
      blog.body.should == "roar"
    end
    
    it "should give the most recent blog body for a given email" do
      blog = Blog.newest("some@dudes.com")
      blog.title.should == "dawg bone"
      blog.body.should == "sharks"
    end
  end
  
  describe "XML" do
    before do
      @xml = "<blog>\n  <title>yessir</title>\n  <body>I hate WALRUSES!</body>\n  <owner>Bob</owner>\n</blog>" 
    end
      
    it 'should serialize to XML' do
      body = Blog.create(:title => "yessir", :body => "I hate WALRUSES!", :owner => "Bob")
      body.to_xml.to_s.should == @xml
    end
  
    it 'should marshal serialized XML to object' do       
      parsed = Blog.from_xml(@xml)
      parsed.body.should == "I hate WALRUSES!"
      parsed.owner.should == "Bob"
    end
  end
end
