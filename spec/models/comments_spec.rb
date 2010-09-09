require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "user" do
    before do
      @user = Factory.create :user
      @group = @user.group(:name => "Doofuses")

      @user2 = Factory.create(:user)
      @group2 = @user2.group(:name => "Lame-faces")
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


        request = @user.send_friend_request_to(@user2, @group)
        reversed_request = @user2.accept_friend_request( request.id, @group2.id )
        @user.receive reversed_request.to_diaspora_xml
        
        @person = Factory.create(:person)
        @person2 = Factory.create(:person) 
        @person_status = Factory.build(:status_message, :person => @person)
        @user_status = Factory.build(:status_message, :person => @user.person)
      end
    
      it "should send a user's comment on a person's post to that person" do
        message_queue.should_receive(:add_post_request)
        @user.comment "yo", :on => @person_status
      end
    
      it 'should send a user comment on his own post to lots of people' do
        allowed_urls = @user.friends.map!{ |x| x = x.receive_url }
        message_queue.should_receive(:add_post_request).with(allowed_urls, anything)
        @user.comment "yo", :on => @user_status
      end
    
      it 'should send a comment a person made on your post to all people' do
        message_queue.should_receive(:add_post_request)
        comment = Comment.new(:person_id => @person.id, :text => "balls", :post => @user_status)
        @user.receive(comment.to_diaspora_xml)
      end
       it 'should send a comment a user made on your post to all people' do
        message_queue.should_receive(:add_post_request).twice
        comment = @user2.comment( "balls", :on => @user_status)
        @user.receive(comment.to_diaspora_xml)
      end
    
      it 'should not send a comment a person made on his own post to anyone' do
        message_queue.should_not_receive(:add_post_request)
        comment = Comment.new(:person_id => @person.id, :text => "balls", :post => @person_status)
        @user.receive(comment.to_diaspora_xml)
      end
      it 'should not send a comment a person made on a person post to anyone' do
        message_queue.should_not_receive(:add_post_request)
        comment = Comment.new(:person_id => @person2.id, :text => "balls", :post => @person_status)
        @user.receive(comment.to_diaspora_xml)
      end
    end
    describe 'serialization' do
      it 'should serialize the commenter' do
        commenter = Factory.create(:user)
        commenter_group = commenter.group :name => "bruisers"
        friend_users(@user, @group, commenter, commenter_group)
        post = @user.post :status_message, :message => "hello", :to => @group.id
        comment = commenter.comment "Fool!", :on => post
        comment.person.should_not == @user.person
        comment.to_diaspora_xml.include?(commenter.person.id.to_s).should be true
      end
    end
  end
end
