#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Comment do
  let(:user)    {Factory.create :user}
  let(:aspect)  {user.aspect(:name => "Doofuses")}

  let(:user2)   {Factory.create(:user)}
  let(:aspect2) {user2.aspect(:name => "Lame-faces")}

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

    it 'should receive a comment from a person not on the pod' do
      user3 = Factory.create(:user)
      aspect3 = user3.aspect(:name => "blah")

      friend_users(user, aspect, user3, aspect3)

      comment = Comment.new(:person_id => user3.person.id, :text => "hey", :post => @user_status)
      comment.creator_signature = comment.sign_with_key(user3.encryption_key)
      comment.post_creator_signature = comment.sign_with_key(user.encryption_key)

      xml = user.salmon(comment).xml_for(user2)

      user3.person.delete
      user3.delete

      @user_status.reload
      @user_status.comments.should == []
      user2.receive_salmon(xml)
      @user_status.reload
      @user_status.comments.include?(comment).should be true
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
      comment = Comment.new(:person_id => @person.id, :text => "balls", :post => @user_status)
      User::QUEUE.should_receive(:add_post_request).twice
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
      comment = Comment.new(:person_id => @person.id, :text => "balls", :post => @person_status)
      user.receive comment.to_diaspora_xml, @person
    end

    it 'should not send a comment a person made on a person post to anyone' do
      User::QUEUE.should_not_receive(:add_post_request)
      comment = Comment.new(:person_id => @person2.id, :text => "balls", :post => @person_status)
      user.receive comment.to_diaspora_xml, @person
    end
    after(:all) do
      unstub_mocha_stubs
    end
  end

    it 'should not clear the aspect post array on receiving a comment' do
      aspect.post_ids.include?(@user_status.id).should be true
      comment = Comment.new(:person_id => @person.id, :text => "balls", :post => @user_status)

      user.receive comment.to_diaspora_xml, @person

      aspect.reload
      aspect.post_ids.include?(@user_status.id).should be true
    end
  end
  describe 'serialization' do
    it 'should serialize the commenter' do
      commenter = Factory.create(:user)
      commenter_aspect = commenter.aspect :name => "bruisers"
      friend_users(user, aspect, commenter, commenter_aspect)
      post = user.post :status_message, :message => "hello", :to => aspect.id
      comment = commenter.comment "Fool!", :on => post
      comment.person.should_not == user.person
      comment.to_diaspora_xml.include?(commenter.person.id.to_s).should be true
    end
  end
end
