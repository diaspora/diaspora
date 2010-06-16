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
end 
