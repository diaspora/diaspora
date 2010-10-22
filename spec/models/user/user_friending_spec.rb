
#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:user) { Factory.create :user }
  let(:aspect) { user.aspect(:name => 'heroes') }
  let(:aspect1) { user.aspect(:name => 'other') }
  let(:friend) { Factory.create(:person) }

  let(:person_one) { Factory.create :person }
  let(:person_two) { Factory.create :person }

  let(:user2) { Factory.create :user }
  let(:aspect2) { user2.aspect(:name => "aspect two") }

  before do
    deliverable = Object.new
    deliverable.stub!(:deliver)
    Notifier.stub!(:new_request).and_return(deliverable)
  end

  context 'friend requesting' do
    it "should assign a request to a aspect" do
      aspect.requests.size.should == 0

      user.send_friend_request_to(friend, aspect)

      aspect.reload
      aspect.requests.size.should == 1
    end

    it "should be able to accept a pending friend request" do
      r = Request.instantiate(:to => user.receive_url, :from => friend)
      r.save

      proc { user.accept_friend_request(r.id, aspect.id) }.should change {
        Request.for_user(user).all.count }.by(-1)
    end

    it 'should be able to ignore a pending friend request' do
      friend = Factory.create(:person)
      r = Request.instantiate(:to => user.receive_url, :from => friend)
      r.save

      proc { user.ignore_friend_request(r.id) }.should change {
        Request.for_user(user).count }.by(-1)
    end

    it 'should not be able to friend request an existing friend' do
      user.friends << friend
      user.save

      proc { user.send_friend_request_to(friend, aspect) }.should raise_error
    end

    it 'should not be able to friend request yourself' do
      proc { user.send_friend_request_to(nil, aspect) }.should raise_error(RuntimeError, /befriend yourself/)
    end


    describe 'multiple users accepting/rejecting the same person' do

      before do
        user.pending_requests.empty?.should be true
        user.friends.empty?.should be true
        user2.pending_requests.empty?.should be true
        user2.friends.empty?.should be true

        @request       = Request.instantiate(:to => user.receive_url, :from => person_one)
        @request_two   = Request.instantiate(:to => user2.receive_url, :from => person_one)
        @request_three =  Request.instantiate(:to => user2.receive_url, :from => user.person)

        @req_xml       = @request.to_diaspora_xml
        @req_two_xml   = @request_two.to_diaspora_xml
        @req_three_xml = @request_three.to_diaspora_xml

        @request.destroy
        @request_two.destroy
        @request_three.destroy
      end

      context 'request from one remote person to one local user' do
        before do
          user2.receive @req_three_xml, user.person
        end
        it 'should befriend the user other user on the same pod' do
          proc {
            user2.accept_friend_request @request_three.id, aspect2.id
          }.should_not change(Person, :count)
          user2.friends.include?(user.person).should be true
        end

        it 'should not delete the ignored user on the same pod' do
          proc {
            user2.ignore_friend_request @request_three.id
          }.should_not change(Person, :count)
          user2.friends.include?(user.person).should be false
        end

        it 'sends an email to the receiving user' do
          mail_obj = mock("mailer")
          mail_obj.should_receive(:deliver)
          Notifier.should_receive(:new_request).and_return(mail_obj)
          user.receive @req_xml, person_one
        end

        it 'should send a an email saying your friend request was confirmed' do
          pending
        end
      end
      context 'Two users receiving requests from one person' do
        before do
          user.receive @req_xml, person_one
          user2.receive @req_two_xml, person_one
        end

        it 'should both users should befriend the same person' do
          user.accept_friend_request @request.id, aspect.id
          user.friends.include?(person_one).should be true

          user2.accept_friend_request @request_two.id, aspect2.id
          user2.friends.include?(person_one).should be true
        end

        it 'should keep the person around if one of the users rejects him' do
          user.accept_friend_request @request.id, aspect.id
          user.friends.include?(person_one).should be true

          user2.ignore_friend_request @request_two.id
          user2.friends.include?(person_one).should be false
        end

        it 'should keep the person around if the users ignores them' do
          user.ignore_friend_request user.pending_requests.first.id
          user.friends.include?(person_one).should be false

          user2.ignore_friend_request user2.pending_requests.first.id #@request_two.id
          user2.friends.include?(person_one).should be false
        end
      end


    end

    describe 'a user accepting rejecting multiple people' do
      before do
        user.pending_requests.empty?.should be true
        user.friends.empty?.should be true

        @request = Request.instantiate(:to => user.receive_url, :from => person_one)
        @request_two = Request.instantiate(:to => user.receive_url, :from => person_two)
      end

      it "keeps the right counts of friends" do
        user.receive_friend_request @request

        person_two.destroy
        user.pending_requests.size.should be 1
        user.friends.size.should be 0

        user.receive_friend_request @request_two
        user.pending_requests.size.should be 2
        user.friends.size.should be 0

        user.accept_friend_request @request.id, aspect.id
        user.pending_requests.size.should be 1
        user.friends.size.should be 1
        user.friends.include?(person_one).should be true

        user.ignore_friend_request @request_two.id
        user.pending_requests.size.should be 0
        user.friends.size.should be 1
        user.friends.include?(person_two).should be false
      end
    end

    describe 'unfriending' do
      before do
        friend_users(user, aspect, user2, aspect2)
      end

      it 'should unfriend the other user on the same seed' do
        lambda { user2.unfriend user.person }.should change {
          user2.friends.count }.by(-1)
        aspect2.reload.people.count.should == 0
      end

      it 'is unfriended by another user' do
        lambda { user.unfriended_by user2.person }.should change {
          user.friends.count }.by(-1)
        aspect.reload.people.count.should == 0
      end

      it 'should remove the friend from all aspects they are in' do
        user.add_person_to_aspect(user2.person.id, aspect1.id)
        lambda { user.unfriended_by user2.person }.should change {
          user.friends.count }.by(-1)
        aspect.reload.people.count.should == 0
        aspect1.reload.people.count.should == 0
      end

      context 'with a post' do
        before do
          @message = user.post(:status_message, :message => "hi", :to => aspect.id)
          user2.receive @message.to_diaspora_xml.to_s, user.person
          user2.unfriend user.person
          user.unfriended_by user2.person
        end
        it "deletes the unfriended user's posts from visible_posts" do
          user.reload.raw_visible_posts.include?(@message.id).should be_false
        end
        it "deletes the unfriended user's posts from the aspect's posts" do
          aspect2.posts.include?(@message).should be_false
        end
      end
    end
  end
end
