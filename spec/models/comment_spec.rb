#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Comment do
  let(:user)    {Factory.create :user}
  let(:aspect)  {user.aspect(:name => "Doofuses")}

  let(:user2)   {Factory.create(:user)}
  let(:aspect2) {user2.aspect(:name => "Lame-faces")}

  it 'validates that the handle belongs to the person' do
    user_status = user.post(:status_message, :message => "hello", :to => aspect.id)
    comment = Comment.new(:person_id => user2.person.id, :text => "hey", :post => user_status)
    comment.valid?
    comment.errors.full_messages.should include "Diaspora handle and person handle must match"
  end

  describe 'User#comment' do
    before do
      @status = user.post(:status_message, :message => "hello", :to => aspect.id)
    end

    it "should be able to comment on his own status" do
      @status.comments.should == []

      user.comment "Yeah, it was great", :on => @status
      @status.reload.comments.first.text.should == "Yeah, it was great"
    end

    it "should be able to comment on a person's status" do
      user2.comment "sup dog", :on => @status
      @status.reload.comments.first.text.should == "sup dog"
    end
  end

  it 'should not send out comments when we have no people' do
    status = Factory.create(:status_message, :person => user.person)
    User::QUEUE.should_not_receive(:add_post_request)
    user.comment "sup dog", :on => status
  end

  describe 'comment propagation' do
    before do
      friend_users(user, aspect, user2, aspect2)

      @person = Factory.create(:person)
      user.activate_friend(@person, Aspect.first(:id => aspect.id))

      @person2 = Factory.create(:person)
      @person_status = Factory.build(:status_message, :person => @person)

      user.reload
      @user_status = user.post :status_message, :message => "hi", :to => aspect.id

      aspect.reload
      user.reload
    end

    it "should send a user's comment on a person's post to that person" do
      User::QUEUE.should_receive(:add_post_request)
      user.comment "yo", :on => @person_status
    end

    it 'should send a user comment on his own post to lots of people' do

      User::QUEUE.should_receive(:add_post_request).twice
      user.comment "yo", :on => @user_status
    end

    it 'should send a comment a person made on your post to all people' do
      comment = Comment.new(:person_id => @person.id, :diaspora_handle => @person.diaspora_handle,  :text => "cats", :post => @user_status)
      User::QUEUE.should_receive(:add_post_request).twice
      Person.should_receive(:by_webfinger).and_return(@person)
      user.receive comment.to_diaspora_xml, @person
    end

    it 'should send a comment a user made on your post to all people' do
      comment = user2.comment( "balls", :on => @user_status)
      User::QUEUE.should_receive(:add_post_request).twice
      user.receive comment.to_diaspora_xml, user2.person
    end

    context 'posts from a remote person' do
      before(:all) do
        stub_comment_signature_verification
      end
    it 'should not send a comment a person made on his own post to anyone' do
      User::QUEUE.should_not_receive(:add_post_request)
      comment = Comment.new(:person_id => @person.id,  :diaspora_handle => @person.diaspora_handle, :text => "cats", :post => @person_status)
      user.receive comment.to_diaspora_xml, @person
    end

    it 'should not send a comment a person made on a person post to anyone' do
      User::QUEUE.should_not_receive(:add_post_request)
      comment = Comment.new(:person_id => @person2.id,  :diaspora_handle => @person.diaspora_handle, :text => "cats", :post => @person_status)
      user.receive comment.to_diaspora_xml, @person
    end
    after(:all) do
      unstub_mocha_stubs
    end
  end

    it 'should not clear the aspect post array on receiving a comment' do
      aspect.post_ids.include?(@user_status.id).should be true
      comment = Comment.new(:person_id => @person.id, :diaspora_handle => @person.diaspora_handle, :text => "cats", :post => @user_status)

      user.receive comment.to_diaspora_xml, @person

      aspect.reload
      aspect.post_ids.include?(@user_status.id).should be true
    end
  end
  describe 'serialization' do
    it 'should serialize the handle and not the sender' do
      commenter = Factory.create(:user)
      commenter_aspect = commenter.aspect :name => "bruisers"
      friend_users(user, aspect, commenter, commenter_aspect)
      post = user.post :status_message, :message => "hello", :to => aspect.id
      comment = commenter.comment "Fool!", :on => post
      comment.person.should_not == user.person
      xml = comment.to_diaspora_xml
      xml.include?(commenter.person.id.to_s).should be false
      xml.include?(commenter.diaspora_handle).should be true
    end
  end

  describe 'comments' do
    before do
      friend_users(user, aspect, user2, aspect2)
      @remote_message = user2.post :status_message, :message => "hello", :to => aspect2.id


      @message = user.post :status_message, :message => "hi", :to => aspect.id
    end
    it 'should attach the creator signature if the user is commenting' do
      user.comment "Yeah, it was great", :on => @remote_message
      @remote_message.comments.first.signature_valid?.should be true
    end

    it 'should sign the comment if the user is the post creator' do
      message = user.post :status_message, :message => "hi", :to => aspect.id
      user.comment "Yeah, it was great", :on => message
      message.comments.first.signature_valid?.should be true
      message.comments.first.verify_post_creator_signature.should be true
    end

    it 'should verify a comment made on a remote post by a different friend' do
      comment = Comment.new(:person => user2.person, :text => "cats", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key,user2.encryption_key)
      comment.signature_valid?.should be true
      comment.verify_post_creator_signature.should be false
      comment.post_creator_signature = comment.send(:sign_with_key,user.encryption_key)
      comment.verify_post_creator_signature.should be true
    end

    it 'should reject comments on a remote post with only a creator sig' do
      comment = Comment.new(:person => user2.person, :text => "cats", :post => @remote_message)
      comment.creator_signature = comment.send(:sign_with_key,user2.encryption_key)
      comment.signature_valid?.should be true
      comment.verify_post_creator_signature.should be false
    end

    it 'should receive remote comments on a user post with a creator sig' do
      comment = Comment.new(:person => user2.person, :text => "cats", :post => @message)
      comment.creator_signature = comment.send(:sign_with_key,user2.encryption_key)
      comment.signature_valid?.should be true
      comment.verify_post_creator_signature.should be false
    end

  end

end
