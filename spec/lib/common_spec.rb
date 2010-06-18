require File.dirname(__FILE__) + '/../spec_helper'


include Diaspora

describe Diaspora do

  describe Webhooks do
    before do
      @user = Factory.create(:user)
      @post = Factory.build(:post)
    end

    it "should add the following methods to Post on inclusion" do
      @post.respond_to?(:notify_friends).should be true
      @post.respond_to?(:prep_webhook).should be true
      @post.respond_to?(:friends_with_permissions).should be true
    end

    it "should convert an object to a proper webhook" do
      @post.prep_webhook.should == @post.to_xml.to_s
    end

    it "should retrieve all valid friend endpoints" do
      Factory.create(:friend, :url => "http://www.bob.com")
      Factory.create(:friend, :url => "http://www.alice.com")
      Factory.create(:friend, :url => "http://www.jane.com")

      @post.friends_with_permissions.should include("http://www.bob.com/receive/")
      @post.friends_with_permissions.should include("http://www.alice.com/receive/")
      @post.friends_with_permissions.should include("http://www.jane.com/receive/")
    end

    it "should send all prepped webhooks to be processed" do
      MessageHandler.any_instance.stubs(:add_post_request).returns true
      MessageHandler.any_instance.stubs(:process).returns true
      @post.notify_friends.should be true
    end
  
    it "should check that it only sends a user's posts to their friends" do
      Factory.create(:friend, :url => "http://www.bob.com")
      Factory.create(:friend, :url => "http://www.alice.com")
      Factory.create(:status_message)
      Factory.create(:bookmark)

      # this is a messagequeue thing; out of scope for webhooks action
    end

    it "should ensure no duplicate url posts" do
      pending
      # this is a messagequeue thing; out of scope for webhooks action
      
    end

    it "should build an xml object containing multiple Post types" do
      Factory.create(:status_message)
      Factory.create(:bookmark)

      stream = Post.stream
      xml = Post.build_xml_for(stream)
      xml.should include "<status_message>"
      xml.should include "<bookmark>"
    end
  end

end
