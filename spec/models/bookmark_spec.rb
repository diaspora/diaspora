require File.dirname(__FILE__) + '/../spec_helper'

describe Bookmark do
  it "should have a link" do
    bookmark = Bookmark.new
    bookmark.valid?.should be false
    bookmark.link = "http://angjoo.com/"
    bookmark.valid?.should be true
  end
  
  it "should add an owner if none is present" do
    User.create(:email => "bob@aol.com", :password => "big bux")
    n = Bookmark.create(:link => "http://www.validurl.com/")
    n.owner.should == "bob@aol.com"
  end
end