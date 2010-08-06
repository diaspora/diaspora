require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "user" do
    before do
      @user = Factory.create :user
      @user.person.save
    end
    it "should be able to comment on his own status" do
      status = Factory.create(:status_message, :person => @user.person)
      status.comments.should == []

      @user.comment "Yeah, it was great", :on => status
      StatusMessage.first.comments.first.text.should == "Yeah, it was great"
    end

    it "should be able to comment on a person's status" do
      person= Factory.create :person
      status = Factory.create(:status_message, :person => person)
      @user.comment "sup dog", :on => status
      
      StatusMessage.first.comments.first.text.should == "sup dog"
      StatusMessage.first.comments.first.person.should == @user.person
    end

    it 'should not send out comments when we have no people' do
      status = Factory.create(:status_message, :person => @user.person)
      message_queue.should_not_receive(:add_post_request)
      @user.comment "sup dog", :on => status
    end

    describe 'comment propagation' do
      before do
        @person = Factory.create(:person)
        @user.friends << Factory.create(:person)
        @user.save
        @person2 = Factory.create(:person) 
        @person_status = Factory.build(:status_message, :person => @person)
        @user_status = Factory.build(:status_message, :person => @user.person)
      end
    
      it "should send a user's comment on a person's post to that person" do
        message_queue.should_receive(:add_post_request)
        @user.comment "yo", :on => @person_status
      end
    
      it 'should send a user comment on his own post to lots of people' do
        allowed_urls = @user_status.people_with_permissions.map!{|x| x = x.url + "receive/"}
        message_queue.should_receive(:add_post_request).with(allowed_urls, anything)
        @user.comment "yo", :on => @user_status
      end
    
      it 'should send a comment a person made on your post to all people' do
        message_queue.should_receive(:add_post_request)
        @person.comment "balls", :on => @user_status
      end
    
      it 'should not send a comment a person made on his own post to anyone' do
        message_queue.should_not_receive(:add_post_request)
        @person.comment "balls", :on => @person_status
      end
      it 'should not send a comment a person made on a person post to anyone' do
        message_queue.should_not_receive(:add_post_request)
        @person2.comment "balls", :on => @person_status
      end
    end
  end
end
