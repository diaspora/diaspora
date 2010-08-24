require File.dirname(__FILE__) + '/../spec_helper'

include Diaspora

describe Diaspora do

  describe Webhooks do
    before do
      @user   = Factory.create(:user, :email => "bob@aol.com")
      @group  = @user.group(:name => "losers")
    end

    describe "body" do
      before do
        @post = Factory.build(:status_message, :person => @user.person)
      end

      it "should add the following methods to Post on inclusion" do
        @post.respond_to?(:to_diaspora_xml).should be true
      end

      it "should send an owners post to their people" do
        message_queue.should_receive :process
        @user.post :status_message, :message => "hi", :to => @group.id 
      end
    
      it "should check that it does not send a person's post to an owners people" do
        message_queue.should_not_receive(:add_post_request) 
        Factory.create(:status_message, :person => Factory.create(:person))
      end

    end
  end
end
