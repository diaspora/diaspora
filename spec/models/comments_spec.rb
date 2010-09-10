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
      User::QUEUE.should_not_receive(:add_post_request)
      @user.comment "sup dog", :on => status
    end

    describe 'comment propagation' do
      before do
        friend_users(@user, Group.first(:id => @group.id), @user2, @group2)

        @person = Factory.create(:person)
        @user.activate_friend(@person, Group.first(:id => @group.id))

        @person2 = Factory.create(:person) 
        @person_status = Factory.build(:status_message, :person => @person)

        @user.reload
        @user_status = @user.post :status_message, :message => "hi", :to => @group.id

        @group.reload
        @user.reload
      end
    
      it 'should have the post in the groups post list' do
        group = Group.first(:id => @group.id)
        group.people.size.should == 2
        group.post_ids.include?(@user_status.id).should be true
      end

      it "should send a user's comment on a person's post to that person" do
        User::QUEUE.should_receive(:add_post_request)
        @user.comment "yo", :on => @person_status
      end
    
      it 'should send a user comment on his own post to lots of people' do

        User::QUEUE.should_receive(:add_post_request).twice
        @user.comment "yo", :on => @user_status
      end
    
      it 'should send a comment a person made on your post to all people' do
        comment = Comment.new(:person_id => @person.id, :text => "balls", :post => @user_status)
        User::QUEUE.should_receive(:add_post_request).twice
        @user.receive(comment.to_diaspora_xml)
      end
      
      it 'should send a comment a user made on your post to all people' do
        
        comment = @user2.comment( "balls", :on => @user_status)
        User::QUEUE.should_receive(:add_post_request).twice
        @user.receive(comment.to_diaspora_xml)
      end
    
      it 'should not send a comment a person made on his own post to anyone' do
        User::QUEUE.should_not_receive(:add_post_request)
        comment = Comment.new(:person_id => @person.id, :text => "balls", :post => @person_status)
        @user.receive(comment.to_diaspora_xml)
      end
      
      it 'should not send a comment a person made on a person post to anyone' do
        User::QUEUE.should_not_receive(:add_post_request)
        comment = Comment.new(:person_id => @person2.id, :text => "balls", :post => @person_status)
        @user.receive(comment.to_diaspora_xml)
      end

      it 'should not clear the group post array on receiving a comment' do
        @group.post_ids.include?(@user_status.id).should be true
        comment = Comment.new(:person_id => @person.id, :text => "balls", :post => @user_status)

        @user.receive(comment.to_diaspora_xml)

        @group.reload
        @group.post_ids.include?(@user_status.id).should be true
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
