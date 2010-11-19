#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::UserModules::Connecting do
  let(:user) { make_user }
  let(:aspect) { user.aspects.create(:name => 'heroes') }
  let(:aspect1) { user.aspects.create(:name => 'other') }
  let(:person) { Factory.create(:person) }

  let(:person_one) { Factory.create :person }
  let(:person_two) { Factory.create :person }
  let(:person_three) { Factory.create :person }

  let(:user2) { make_user }
  let(:aspect2) { user2.aspects.create(:name => "aspect two") }

  describe '#send_contact_request_to' do
    it "should assign a request to a aspect for the user that sent it out" do
      aspect.requests.size.should == 0

      user.send_contact_request_to(person, aspect)

      aspect.reload
      aspect.requests.size.should == 1
    end
  end

  context 'contact requesting' do
    describe  '#receive_contact_request' do
      it 'adds a request to pending if it was not sent by user' do
        r = Request.instantiate(:to => user.person, :from => person)
        r.save
        user.receive_contact_request(r)
        user.reload.pending_requests.should include r
      end

      it 'should autoaccept a request the user sent' do
        request = user.send_contact_request_to(user2.person, aspect)
        user.contact_for(user2.person).should be_nil
        user.receive_request(request.reverse_for(user2), user2.person)
        user.contact_for(user2.person).should_not be_nil
      end
    end

    context 'received a contact request' do

      let(:request_for_user) {Request.instantiate(:to => user.person, :from => person)}
      let(:request2_for_user) {Request.instantiate(:to => user.person, :from => person_one)}
      let(:request_from_myself) {Request.instantiate(:to => user.person, :from => user.person)}
      before do
        request_for_user.save
        user.receive(request_for_user.to_diaspora_xml, person)
        @received_request = Request.from(person).to(user.person).first(:sent => false)
        user.receive(request2_for_user.to_diaspora_xml, person_one)
        @received_request2 = Request.from(person_one).to(user.person).first(:sent => false)
        user.reload
      end

      it "should delete an accepted contact request from pending_requests" do
        proc {
          user.accept_contact_request(@received_request, aspect)
        }.should change(user.reload.pending_requests, :count ).by(-1)
      end
      it "should delete an accepted contact request" do
        proc {
          user.accept_contact_request(@received_request, aspect)
        }.should change(Request, :count ).by(-1)
      end
      it 'should be able to ignore a pending contact request' do
        proc { user.ignore_contact_request(@received_request.id) }.should change(
          user.reload.pending_requests, :count ).by(-1)
      end

      it 'should ignore a contact request from yourself' do
        reversed_request = request_from_myself.reverse_for(user)

        proc { user.receive_contact_request(reversed_request)
          }.should raise_error /request from himself/
      end
    end

    it 'should not be able to contact request an existing contact' do
      connect_users(user, aspect, user2, aspect2)
      proc { user.send_contact_request_to(user2.person, aspect1) 
      }.should raise_error(MongoMapper::DocumentNotValid, /already connected/)
    end

    it 'should not be able to contact request yourself' do
      proc { user.send_contact_request_to(nil, aspect) 
      }.should raise_error(MongoMapper::DocumentNotValid)
    end

    it 'should send an email on acceptance if a contact request' do
      Request.should_receive(:send_request_accepted)
      request = user.send_contact_request_to(user2.person, aspect)
      user.receive_request(request.reverse_for(user2), user2.person)
    end


    describe 'multiple users accepting/rejecting the same person' do

      before do
        user.pending_requests.empty?.should be true
        user.contacts.empty?.should be true
        user2.pending_requests.empty?.should be true
        user2.contacts.empty?.should be true

        @request       = Request.instantiate(:to => user.person, :from => person_one)
        @request_two   = Request.instantiate(:to => user2.person, :from => person_one)
        @request_three =  Request.instantiate(:to => user2.person, :from => user.person)

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
        it 'should connect the user other user on the same pod' do
          proc {
            user2.accept_contact_request @received_request, aspect2
          }.should_not change(Person, :count)
          user2.contact_for(user.person).should_not be_nil
        end

        it 'should not delete the ignored user on the same pod' do
          proc {
            user2.ignore_contact_request @received_request.id
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

        describe '#accept_contact_request' do
          it 'should both users should connect the same person' do
            user.accept_contact_request @req_to_user, aspect
            user.contact_for(person_one).should_not be_nil

            user2.accept_contact_request @req_to_user2, aspect2
            user2.contact_for(person_one).should_not be_nil
          end

          it 'should keep the person around if one of the users rejects him' do
            user.accept_contact_request @req_to_user, aspect
            user.contact_for(person_one).should_not be_nil

            user2.ignore_contact_request @req_to_user2.id
            user2.contact_for(person_one).should be_nil
          end
        end


        it 'should keep the person around if the users ignores them' do
          user.ignore_contact_request user.pending_requests.first.id
          user.contact_for(person_one).should be_nil

          user2.ignore_contact_request user2.pending_requests.first.id #@request_two.id
          user2.contact_for(person_one).should be_nil
        end
      end


    end

    describe 'a user accepting rejecting multiple people' do
      before do
        user.pending_requests.empty?.should be true
        user.contacts.empty?.should be true

        @request = Request.instantiate(:to => user.person, :from => person_one)
        @request_two = Request.instantiate(:to => user.person, :from => person_two)
      end

      it "keeps the right counts of contacts" do
        received_req = user.receive @request.to_diaspora_xml, person_one

        user.reload.pending_requests.size.should == 1
        user.contacts.size.should be 0

        received_req2 = user.receive @request_two.to_diaspora_xml, person_two
        user.reload.pending_requests.size.should == 2
        user.contacts.size.should be 0

        user.accept_contact_request received_req, aspect
        user.reload.pending_requests.size.should == 1
        user.contacts.size.should be 1
        user.contact_for(person_one).should_not be_nil

        user.ignore_contact_request received_req2.id
        user.reload.pending_requests.size.should == 0
        user.contacts.size.should be 1
        user.contact_for(person_two).should be_nil
      end
    end

    describe 'disconnecting' do
      before do
        connect_users(user, aspect, user2, aspect2)
      end

      it 'should disconnect the other user on the same seed' do
        lambda { 
          user2.disconnect user.person }.should change {
          user2.reload.contacts.count }.by(-1)
        aspect2.reload.contacts.count.should == 0
      end

      it 'is disconnected by another user' do
        lambda { user.disconnected_by user2.person }.should change {
          user.contacts.count }.by(-1)
        aspect.reload.contacts.count.should == 0
      end

      it 'should remove the contact from all aspects they are in' do
        user.add_person_to_aspect(user2.person.id, aspect1.id)
        aspect.reload.contacts.count.should == 1
        aspect1.reload.contacts.count.should == 1
        lambda { user.disconnected_by user2.person }.should change {
          user.contacts.count }.by(-1)
        aspect.reload.contacts.count.should == 0
        aspect1.reload.contacts.count.should == 0
      end

      context 'with a post' do
        before do
          @message = user.post(:status_message, :message => "hi", :to => aspect.id)
        end

        it "deletes the disconnected user's posts from visible_posts" do
          user2.reload.raw_visible_posts.include?(@message).should be_true
          user2.disconnect user.person
          user2.reload.raw_visible_posts.include?(@message).should be_false
        end

        it "deletes the disconnected user's posts from the aspect's posts" do
          Post.count.should == 1
          aspect2.reload.posts.include?(@message).should be_true
          user2.disconnect user.person
          aspect2.reload.posts.include?(@message).should be_false
          Post.count.should == 1
        end
      end
    end
  end
end
