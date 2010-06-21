require File.dirname(__FILE__) + '/../spec_helper'

describe Bookmark do 
  it "should have a link" do
    bookmark = Factory.build(:bookmark, :link => nil)
    bookmark.valid?.should be false
    bookmark.link = "http://angjoo.com/"
    bookmark.valid?.should be true
  end
  
  it "should add an owner if none is present" do
    Factory.create(:user, :email => "bob@aol.com")
    n = Factory.create(:bookmark)
    n.owner.should == "bob@aol.com" 
  end

  it 'should validate its link' do
    bookmark = Factory.build(:bookmark)

    #links changed valid
    bookmark.link = "google.com"
    bookmark.valid?.should == true 
    bookmark.link.should == "http://google.com/"

    bookmark.link = "www.google.com"
    bookmark.valid?.should == true
    bookmark.link.should == "http://www.google.com/"

    bookmark.link = "google.com/"
    bookmark.valid?.should == true
    bookmark.link.should == "http://google.com/"

    bookmark.link = "www.google.com/"
    bookmark.valid?.should == true
    bookmark.link.should == "http://www.google.com/"

    bookmark.link = "http://google.com"
    bookmark.valid?.should == true
    bookmark.link.should == "http://google.com/"

    bookmark.link = "http://www.google.com"
    bookmark.valid?.should == true

    #invalid links
    bookmark.link = "zsdvzxdg"
    bookmark.valid?.should == false
    bookmark.link = "sdfasfa.c"
    bookmark.valid?.should == false
    bookmark.link = "http://.com/"
    bookmark.valid?.should == false
    bookmark.link = "http://www..com/"
    bookmark.valid?.should == false
    bookmark.link = "http:/www.asodij.com/"
    bookmark.valid?.should == false
    bookmark.link = "https:/www.asodij.com/"
    bookmark.valid?.should == false
    bookmark.link = "http:///www.asodij.com/"
    bookmark.valid?.should == false
  end

  describe "XML" do
    it 'should serialize to XML' do
      Factory.create(:user)
      message = Factory.create(:bookmark, :title => "Reddit", :link => "http://reddit.com/")
      message.to_xml.to_s.should include "<title>Reddit</title>"
      message.to_xml.to_s.should include "<link>http://reddit.com/</link>"
    end
  
    it 'should marshal serialized XML to object' do       
      xml = "<bookmark><title>Reddit</message><link>http://reddit.com/</link><owner>bob@aol.com</owner></bookmark>" 
      parsed = Bookmark.from_xml(xml)
      parsed.title.should == "Reddit"
      parsed.link.should == "http://reddit.com/"
      parsed.owner.should == "bob@aol.com"
      parsed.valid?.should be_true
    end
  end
end 
