require File.dirname(__FILE__) + '/../spec_helper'

describe Bookmark do 
  it "should have a link" do
    bookmark = Factory.build(:bookmark, :link => nil)
    bookmark.valid?.should be false
    bookmark.link = "http://angjoo.com/"
    bookmark.valid?.should be true
  end
  
  it 'should validate its link' do
    bookmark = Factory.build(:bookmark)
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
  
  it 'should clean links' do
    bad_links = [
      "google.com",
      "www.google.com",
      "google.com/",
      "www.google.com/",
      "http://google.com",
      "http://www.google.com"
    ]

    bad_links.each{ |link|
       Bookmark.clean_link(link).should satisfy{ |link|
         /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix.match(link)
       }
    }
    
  end

  describe "XML" do
    it 'should serialize to XML' do
      u = Factory.create(:user)
      message = Factory.create(:bookmark, :title => "Reddit", :link => "http://reddit.com/", :person => u.person)
      message.to_xml.to_s.should include "<title>Reddit</title>"
      message.to_xml.to_s.should include "<link>http://reddit.com/</link>"
    end
  
    it 'should marshal serialized XML to object' do       
      xml = "<bookmark><title>Reddit</message><link>http://reddit.com/</link></bookmark>" 
      parsed = Bookmark.from_xml(xml)
      parsed.title.should == "Reddit"
      parsed.link.should == "http://reddit.com/"
      parsed.valid?.should be_true
    end
  end

  describe 'with encryption' do
    before do
      unstub_mocha_stubs
      @user = Factory.create(:user)
    end

    after do
      stub_signature_verification
    end

    it 'should save a signed bookmark' do
      bookmark = @user.post(:bookmark, :title => "I love cryptography", :link => "http://pgp.mit.edu/")
      bookmark.created_at.should_not be nil
    end
  end
end 
