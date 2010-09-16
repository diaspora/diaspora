#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "user" do
    before do
      @user = Factory.create :user
      @aspect = @user.aspect(:name => "Doofuses")

      @user2 = Factory.create(:user)
      @aspect2 = @user2.aspect(:name => "Lame-faces")
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
        friend_users(@user, Aspect.first(:id => @aspect.id), @user2, @aspect2)

        @person = Factory.create(:person)
        @user.activate_friend(@person, Aspect.first(:id => @aspect.id))

        @person2 = Factory.create(:person)
        @person_status = Factory.build(:status_message, :person => @person)

        @user.reload
        @user_status = @user.post :status_message, :message => "hi", :to => @aspect.id

        @aspect.reload
        @user.reload
      end

      it 'should have the post in the aspects post list' do
        aspect = Aspect.first(:id => @aspect.id)
        aspect.people.size.should == 2
        aspect.post_ids.include?(@user_status.id).should be true
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

      it 'should not clear the aspect post array on receiving a comment' do
        @aspect.post_ids.include?(@user_status.id).should be true
        comment = Comment.new(:person_id => @person.id, :text => "balls", :post => @user_status)

        @user.receive(comment.to_diaspora_xml)

        @aspect.reload
        @aspect.post_ids.include?(@user_status.id).should be true
      end
    end
    describe 'serialization' do
      it 'should serialize the commenter' do
        commenter = Factory.create(:user)
        commenter_aspect = commenter.aspect :name => "bruisers"
        friend_users(@user, @aspect, commenter, commenter_aspect)
        post = @user.post :status_message, :message => "hello", :to => @aspect.id
        comment = commenter.comment "Fool!", :on => post
        comment.person.should_not == @user.person
        comment.to_diaspora_xml.include?(commenter.person.id.to_s).should be true
      end
    end
  end
end
