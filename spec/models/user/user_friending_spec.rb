#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:user) {Factory.create :user}
  let(:aspect) {user.aspect(:name => 'heroes')}
  let(:friend) { Factory.create(:person) }

  let(:person_one) {Factory.create :person}
  let(:person_two) {Factory.create :person}
  
  let(:user2)   { Factory.create :user}
  let(:aspect2) { user2.aspect(:name => "aspect two")}

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
      Person.all.count.should == 2
      Request.for_user(user).all.count.should == 1
      user.accept_friend_request(r.id, aspect.id)
      Request.for_user(user).all.count.should == 0
    end

    it 'should be able to ignore a pending friend request' do
      friend = Factory.create(:person)
      r = Request.instantiate(:to => user.receive_url, :from => friend)
      r.save

      Person.count.should == 2

      user.ignore_friend_request(r.id)

      Person.count.should == 2
      Request.count.should == 0
    end

    it 'should not be able to friend request an existing friend' do
      user.friends << friend
      user.save

      proc { user.send_friend_request_to(friend, aspect) }.should raise_error
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

      it 'should befriend the user other user on the same pod' do
        user2.receive @req_three_xml, user.person
        user2.pending_requests.size.should be 1
        user2.accept_friend_request @request_three.id, aspect2.id
        user2.friends.include?(user.person).should be true
        Person.all.count.should be 3
      end

      it 'should not delete the ignored user on the same pod' do
        user2.receive @req_three_xml, user.person
        user2.pending_requests.size.should be 1
        user2.ignore_friend_request @request_three.id
        user2.friends.include?(user.person).should be false
        Person.all.count.should be 3
      end

      it 'should both users should befriend the same person' do
        user.receive @req_xml, person_one
        user.pending_requests.size.should be 1
        user.accept_friend_request @request.id, aspect.id
        user.friends.include?(person_one).should be true

        user2.receive @req_two_xml, person_one
        user2.pending_requests.size.should be 1
        user2.accept_friend_request @request_two.id, aspect2.id
        user2.friends.include?(person_one).should be true
        Person.all.count.should be 3
      end

      it 'should keep the person around if one of the users rejects him' do
        user.receive @req_xml, person_one
        user.pending_requests.size.should be 1
        user.accept_friend_request @request.id, aspect.id
        user.friends.include?(person_one).should be true

        user2.receive @req_two_xml, person_one
        user2.pending_requests.size.should be 1
        user2.ignore_friend_request @request_two.id
        user2.friends.include?(person_one).should be false
        Person.all.count.should be 3
      end

      it 'should keep the person around if the users ignores them' do
        user.receive @req_xml, person_one
        user.pending_requests.size.should be 1
        user.ignore_friend_request user.pending_requests.first.id
        user.friends.include?(person_one).should be false

        user2.receive @req_two_xml, person_one
        user2.pending_requests.size.should be 1
        user2.ignore_friend_request user2.pending_requests.first.id #@request_two.id
        user2.friends.include?(person_one).should be false
        Person.all.count.should be 3
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
        friend_users(user,aspect, user2, aspect2)
      end

      it 'should unfriend the other user on the same seed' do
        user.friends(true).count.should == 1
        user2.friends(true).count.should == 1

        user2.unfriend user.person

        user2.friends(true).count.should == 0
        user.unfriended_by user2.person

        aspect.reload.people(true).count.should == 0
        aspect2.reload.people(true).count.should == 0
      end

      context 'with a post' do
        before do
          @message = user.post(:status_message, :message => "hi", :to => aspect.id)
          user2.receive      @message.to_diaspora_xml.to_s, user.person
          user2.unfriend      user.person
          user.unfriended_by  user2.person
        end
        it "deletes the unfriended user's posts from visible_posts" do
          user.raw_visible_posts(true).include?(@message.id).should be_false
        end
        it "deletes the unfriended user's posts from the aspect's posts" do
          aspect2.posts(true).include?(@message).should be_false
        end
      end
    end
  end
end
