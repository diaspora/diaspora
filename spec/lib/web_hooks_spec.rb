require File.dirname(__FILE__) + '/../spec_helper'

include Diaspora

describe Diaspora do

  describe Webhooks do
    before do
      @user = Factory.create(:user, :email => "bob@aol.com")
      @user.person.save
      @person = Factory.create(:person)
    end

    describe "body" do
      before do
        @post = Factory.build(:status_message, :person => @user.person)
      end

      it "should add the following methods to Post on inclusion" do
        @post.respond_to?(:notify_people).should be true
        @post.respond_to?(:to_diaspora_xml).should be true
        @post.respond_to?(:people_with_permissions).should be true
      end

      it "should convert an object to a proper diaspora entry" do
        @post.to_diaspora_xml.should == "<post>#{@post.to_xml.to_s}</post>"
      end

      it "should retrieve all valid person endpoints" do
        @user.friends << Factory.create(:person, :url => "http://www.bob.com/")
        @user.friends << Factory.create(:person, :url => "http://www.alice.com/")
        @user.friends << Factory.create(:person, :url => "http://www.jane.com/")
        @user.save

        @post.person.owner.reload
                
        @post.people_with_permissions.should == @user.friends
      end

      it "should send an owners post to their people" do
        message_queue.should_receive :process
        @user.post :status_message, :message => "hi" 
      end
    
      it "should check that it does not send a person's post to an owners people" do
        message_queue.should_not_receive(:add_post_request) 
        Factory.create(:status_message, :person => Factory.create(:person))
      end

      it "should ensure one url is created for every person" do
        5.times {@user.friends << Factory.create(:person)}
        @user.save
        
        @post.person.owner.reload
        
        @post.people_with_permissions.size.should == 5
      end

    end
  end

end
