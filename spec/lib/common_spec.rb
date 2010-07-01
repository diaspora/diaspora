require File.dirname(__FILE__) + '/../spec_helper'


include Diaspora

describe Diaspora do

  describe Webhooks do
    before do
      @user = Factory.create(:user, :email => "bob@aol.com")
      @friend = Factory.create(:friend)
    end

    describe "header" do 
      before do
        Factory.create(:status_message)
        Factory.create(:bookmark)
        stream = Post.stream
        @xml = Post.build_xml_for(stream)
      end

      it "should generate" do
        @xml.should include "<head>"
        @xml.should include "</head>"
      end

      it "should provide a sender" do
        @xml.should include "<sender>"
        @xml.should include "</sender>"
      end

      it "should provide the owner's email" do
        @xml.should include "<email>#{User.first.email}</email>"
      end
    end

    describe "body" do
      before do
        @post = Factory.create(:status_message, :person => @user)
      end

      it "should add the following methods to Post on inclusion" do
        @post.respond_to?(:notify_friends).should be true
        @post.respond_to?(:prep_webhook).should be true
        @post.respond_to?(:friends_with_permissions).should be true
      end

      it "should convert an object to a proper webhook" do
        @post.prep_webhook.should == "<post>#{@post.to_xml.to_s}</post>"
      end

      it "should retrieve all valid friend endpoints" do
        Factory.create(:friend, :url => "http://www.bob.com/")
        Factory.create(:friend, :url => "http://www.alice.com/")
        Factory.create(:friend, :url => "http://www.jane.com/")

        @post.friends_with_permissions.should == Friend.all
      end

      it "should send an owners post to their friends" do
        q = Post.send (:class_variable_get, :@@queue)
        q.should_receive :process
        @post.save
      end
    
      it "should check that it does not send a friends post to an owners friends" do
        Post.stub(:build_xml_for).and_return(true) 
        Post.should_not_receive(:build_xml_for)
        
        Factory.create(:status_message, :person => Factory.create(:friend))
      end

      it "should ensure one url is created for every friend" do
        5.times {Factory.create(:friend)}
        @post.friends_with_permissions.size.should == 6
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

end
