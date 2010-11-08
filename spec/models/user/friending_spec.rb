
#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::UserModules::Friending do
  let(:user) { make_user }
  let(:aspect) { user.aspects.create(:name => 'heroes') }
  let(:aspect1) { user.aspects.create(:name => 'other') }
  let(:friend) { Factory.create(:person) }

  let(:person_one) { Factory.create :person }
  let(:person_two) { Factory.create :person }
  let(:person_three) { Factory.create :person }

  let(:user2) { make_user }
  let(:aspect2) { user2.aspects.create(:name => "aspect two") }


  context 'friend requesting' do
    it "should assign a request to a aspect for the user that sent it out" do
      aspect.requests.size.should == 0

      user.send_friend_request_to(friend, aspect)

      aspect.reload
      aspect.requests.size.should == 1
    end

    describe  '#receive_friend_request' do
      it 'adds a request to pending if it was not sent by user' do
        r = Request.instantiate(:to => user.receive_url, :from => friend)
        r.save
        user.receive_friend_request(r)
        user.reload.pending_requests.should include r
      end

      it 'should autoaccept a request the user sent' do
        request = user.send_friend_request_to(user2.person, aspect)
        proc{
          user.receive_friend_request(request.reverse_for(user2))
        }.should change(user.reload.friends, :count).by(1)
      end
    end

    context 'received a friend request' do

      let(:request_for_user) {Request.instantiate(:to => user.receive_url, :from => friend)}
      let(:request2_for_user) {Request.instantiate(:to => user.receive_url, :from => person_one)}
      let(:request_from_myself) {Request.instantiate(:to => user.receive_url, :from => user.person)}
      before do
        request_for_user.save
        user.receive_friend_request(request_for_user)
        user.receive_friend_request(request2_for_user)
        user.reload
      end

      it "should delete an accepted friend request" do
        proc { user.accept_friend_request(request2_for_user.id, aspect.id) }.should change(
          user.reload.pending_requests, :count ).by(-1)
      end

      it 'should be able to ignore a pending friend request' do
        proc { user.ignore_friend_request(request_for_user.id) }.should change(
          user.reload.pending_requests, :count ).by(-1)
      end

      it 'should ignore a friend request from yourself' do
        reversed_request = request_from_myself.reverse_for(user)

        user.pending_requests.delete_all
        user.save

        proc { user.receive_friend_request(reversed_request)
          }.should raise_error /request from himself/
      end
    end

    it 'should not be able to friend request an existing friend' do
      friend_users(user, aspect, user2, aspect2)
      proc { user.send_friend_request_to(user2.person, aspect1) }.should raise_error /already friends/
    end

    it 'should not be able to friend request yourself' do
      proc { user.send_friend_request_to(nil, aspect) }.should raise_error(RuntimeError, /befriend yourself/)
    end

    it 'should send an email on acceptance if a friend request' do
      Request.should_receive(:send_request_accepted)
      request = user.send_friend_request_to(user2.person, aspect)
      user.receive_friend_request(request.reverse_for(user2))
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
          @received_request = user2.receive @req_three_xml, user.person
        end
        it 'should befriend the user other user on the same pod' do
          proc {
            user2.accept_friend_request @received_request.id, aspect2.id
          }.should_not change(Person, :count)
          user2.contact_for(user.person).should_not be_nil
        end

        it 'should not delete the ignored user on the same pod' do
          proc {
            user2.ignore_friend_request @received_request.id
          }.should_not change(Person, :count)
          user2.contact_for(user.person).should be_nil
        end

        it 'sends an email to the receiving user' do
          Request.should_receive(:send_new_request).and_return(true)
          user.receive @req_xml, person_one
        end
      end

      context 'Two users receiving requests from one person' do
        before do
          @req_to_user  = user.receive @req_xml, person_one
          @req_to_user2 = user2.receive @req_two_xml, person_one
        end

        describe '#accept_friend_request' do
          it 'should both users should befriend the same person' do
            user.accept_friend_request @req_to_user.id, aspect.id
            user.contact_for(person_one).should_not be_nil

            user2.accept_friend_request @req_to_user2.id, aspect2.id
            user2.contact_for(person_one).should_not be_nil
          end

          it 'should keep the person around if one of the users rejects him' do
            user.accept_friend_request @req_to_user.id, aspect.id
            user.contact_for(person_one).should_not be_nil

            user2.ignore_friend_request @req_to_user2.id
            user2.contact_for(person_one).should be_nil
          end
        end


        it 'should keep the person around if the users ignores them' do
          user.ignore_friend_request user.pending_requests.first.id
          user.contact_for(person_one).should be_nil

          user2.ignore_friend_request user2.pending_requests.first.id #@request_two.id
          user2.contact_for(person_one).should be_nil
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
        received_req = user.receive @request.to_diaspora_xml, person_one

        user.reload.pending_requests.size.should == 1
        user.friends.size.should be 0

        received_req2 = user.receive @request_two.to_diaspora_xml, person_two
        user.reload.pending_requests.size.should == 2
        user.friends.size.should be 0

        user.accept_friend_request received_req.id, aspect.id
        user.reload.pending_requests.size.should == 1
        user.friends.size.should be 1
        user.contact_for(person_one).should_not be_nil

        user.ignore_friend_request received_req2.id
        user.reload.pending_requests.size.should == 0
        user.friends.size.should be 1
        user.contact_for(person_two).should be_nil
      end
    end

    describe 'unfriending' do
      before do
        friend_users(user, aspect, user2, aspect2)
      end

      it 'should unfriend the other user on the same seed' do
        lambda { 
          user2.unfriend user.person }.should change {
          user2.reload.friends.count }.by(-1)
        aspect2.reload.people.count.should == 0
      end

      it 'is unfriended by another user' do
        lambda { user.unfriended_by user2.person }.should change {
          user.friends.count }.by(-1)
        aspect.reload.people.count.should == 0
      end

      it 'should remove the friend from all aspects they are in' do
        user.add_person_to_aspect(user2.person.id, aspect1.id)
        aspect.reload.people.count.should == 1
        aspect1.reload.people.count.should == 1
        lambda { user.unfriended_by user2.person }.should change {
          user.friends.count }.by(-1)
        aspect.reload.people.count.should == 0
        aspect1.reload.people.count.should == 0
      end

      context 'with a post' do
        before do
          @message = user.post(:status_message, :message => "hi", :to => aspect.id)
        end

        it "deletes the unfriended user's posts from visible_posts" do
          user2.reload.raw_visible_posts.include?(@message).should be_true
          user2.unfriend user.person
          user2.reload.raw_visible_posts.include?(@message).should be_false
        end

        it "deletes the unfriended user's posts from the aspect's posts" do
          Post.count.should == 1
          aspect2.reload.posts.include?(@message).should be_true
          user2.unfriend user.person
          aspect2.reload.posts.include?(@message).should be_false
          Post.count.should == 1
        end
      end
    end
  end
end
