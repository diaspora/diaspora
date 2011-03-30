#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::UserModules::Connecting do
  let(:user) { alice }
  let(:aspect) { user.aspects.create(:name => 'heroes') }
  let(:aspect1) { user.aspects.create(:name => 'other') }
  let(:person) { Factory.create(:person) }

  let(:person_one) { Factory.create :person }
  let(:person_two) { Factory.create :person }
  let(:person_three) { Factory.create :person }

  let(:user2) { eve }
  let(:aspect2) { user2.aspects.create(:name => "aspect two") }

  describe '#send_contact_request_to' do
    it 'should not be able to contact request an existing contact' do
      user.activate_contact(user2.person, aspect1)

      proc {
        user.send_contact_request_to(user2.person, aspect1)
      }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not be able to contact request no-one' do
      proc {
        user.send_contact_request_to(nil, aspect)
      }.should raise_error(ActiveRecord::RecordInvalid)
    end
    it 'creates a pending contact' do
      proc {
        user.send_contact_request_to(user2.person, aspect1)
      }.should change(Contact.unscoped, :count).by(1)
      user.contact_for(user2.person).pending.should == true
      user.contact_for(user2.person).should be_pending
    end
    it 'persists no request for requester' do
      proc {
        user.send_contact_request_to(user2.person, aspect1)
      }.should_not change{Request.where(:recipient_id => user.person.id).count}
    end
    it 'persists a request for the recipient' do
      user.send_contact_request_to(user2.person, aspect1)
      user2.request_from(user.person).should_not be_nil
    end
  end

  context 'contact requesting' do
    describe  '#receive_contact_request' do
      before do
        @r = Request.diaspora_initialize(:to => user.person, :from => person)
      end

      it 'adds a request to pending if it was not sent by user' do
        user.receive_contact_request(@r)
        Request.where(:recipient_id => user.person.id).all.should include @r
      end

      it 'creates no contact' do
        lambda {
          received_req = @r.receive(user, person_one)
        }.should_not change(Contact, :count)
      end

      it 'enqueues a mail job' do
        Resque.should_receive(:enqueue).with(Job::MailRequestReceived, user.id, person.id, anything)
        zord = Postzord::Receiver.new(user, :object => @r, :person => person)
        zord.receive_object
      end
    end

    describe '#receive_request_acceptance' do
      before do
        @original_request = user.send_contact_request_to(user2.person, aspect)
        @acceptance = @original_request.reverse_for(user2)
      end
      it 'connects to the acceptor' do
        @acceptance.receive(user, user2.person)
        user.contact_for(user2.person).should_not be_nil
      end
      it 'deletes the acceptance' do
        @acceptance.receive(user, user2.person)
        Request.where(:sender_id => user2.person.id, :recipient_id => user.person.id).should be_empty
      end
      it 'enqueues a mail job' do
        Resque.should_receive(:enqueue).with(Job::MailRequestAcceptance, user.id, user2.person.id, nil).once
        zord = Postzord::Receiver.new(user, :object => @acceptance, :person => user2.person)
        zord.receive_object
      end
    end

    context 'received a contact request' do
      let(:request_for_user) {Request.diaspora_initialize(:to => user.person, :from => person)}
      let(:request2_for_user) {Request.diaspora_initialize(:to => user.person, :from => person_one)}
      let(:request_from_myself) {Request.diaspora_initialize(:to => user.person, :from => user.person)}
      before do
        Request.diaspora_initialize(:from => person, :to => user.person).save
        Request.diaspora_initialize(:from => person_one, :to => user.person).save

        @received_request = Request.where(:sender_id => person.id, :recipient_id => user.person.id).first
        @received_request2 = Request.where(:sender_id => person_one.id, :recipient_id => user.person.id).first
      end

      it "should delete an accepted contact request" do
        proc {
          user.accept_contact_request(@received_request, aspect)
        }.should change(Request, :count ).by(-1)
      end

      it "should mark the corresponding notification as 'read'" do
        notification = Factory.create(:notification, :target => @received_request)

        Notification.where(:target_id=>@received_request.id).first.unread.should be_true
        user.accept_contact_request(@received_request, aspect)
        Notification.where(:target_id=>@received_request.id).first.unread.should be_false
      end

      it 'should be able to ignore a pending contact request' do
        proc { user.ignore_contact_request(@received_request.id)
        }.should change(Request, :count ).by(-1)
      end

      it 'should ignore a contact request from yourself' do
        reversed_request = request_from_myself.reverse_for(user)

        user.receive_contact_request(reversed_request)
        reversed_request.persisted?.should be false
      end
    end

    describe 'multiple users accepting/rejecting the same person' do

      before do
        @request1 = Request.diaspora_initialize(:to => user.person, :from => person_one)
        @request2 = Request.diaspora_initialize(:to => user2.person, :from => person_one)
        @request3 =  Request.diaspora_initialize(:to => user2.person, :from => user.person)

        @req1_xml = @request1.to_diaspora_xml
        @req2_xml = @request2.to_diaspora_xml
        @req3_xml = @request3.to_diaspora_xml

        @request1.destroy
        @request2.destroy
        @request3.destroy
      end

      context 'request from one remote person to one local user' do
        before do
          zord = Postzord::Receiver.new(user, :person => user.person)
          @received_request = zord.parse_and_receive(@req3_xml)
          @received_request.reload
        end

        it 'should connect the user other user on the same pod' do
          proc {
            user2.accept_contact_request(@received_request, aspect2)
          }.should_not change(Person, :count)
          user2.contact_for(user.person).should_not be_nil
        end

        it 'should not delete the ignored user on the same pod' do

          proc {
            user2.ignore_contact_request(@received_request.id)
          }.should_not change(Person, :count)
          user2.contact_for(user.person).should be_nil
        end
      end

      context 'Two users receiving requests from one person' do
        before do
          zord1 = Postzord::Receiver.new(user, :person => person_one)
          zord2 = Postzord::Receiver.new(user, :person => person_one)

          @req_to_user = zord1.parse_and_receive(@req1_xml)
          @req_to_user2 = zord2.parse_and_receive(@req2_xml)
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
          user.ignore_contact_request Request.where(:recipient_id => user.person.id).first.id
          user.contact_for(person_one).should be_nil

          user2.ignore_contact_request Request.where(:recipient_id => user2.person.id).first.id
          user2.contact_for(person_one).should be_nil
        end
      end


    end

    describe 'a user accepting rejecting multiple people' do
      before do
        request = Request.diaspora_initialize(:to => user.person, :from => person_one)
        @received_request = request.receive(user, person_one)
      end
      describe '#accept_contact_request' do
        it "deletes the received request" do
          lambda {
            user.accept_contact_request(@received_request, aspect)
          }.should change(Request, :count).by(-1)
        end
        it "creates a new contact" do
          lambda {
            user.accept_contact_request(@received_request, aspect)
          }.should change(Contact, :count).by(1)
          user.contact_for(person_one).should_not be_nil
        end
      end
      describe '#ignore_contact_request' do
        it "removes the request" do
          lambda {
            user.ignore_contact_request(@received_request.id)
          }.should change(Request, :count).by(-1)
        end
        it "creates no new contact" do
          lambda {
            user.ignore_contact_request(@received_request)
          }.should_not change(Contact, :count)
        end
      end
    end

    describe 'disconnecting' do

      describe 'disconnected_by' do
        it 'is disconnected by another user' do
          lambda { alice.disconnected_by bob.person }.should change {
            alice.contacts.count }.by(-1)
          alice.aspects.first.contacts.count.should == 0
        end

        it 'deletes incoming requests' do
          alice.send_contact_request_to(eve.person, alice.aspects.first)
          Request.where(:recipient_id => eve.person.id, :sender_id => alice.person.id).first.should_not be_nil
          eve.disconnected_by(alice.person)
          Request.where(:recipient_id => eve.person.id, :sender_id => alice.person.id).first.should be_nil
        end
      end

      it 'disconnects a contact on the same seed' do
        bob.aspects.first.contacts.count.should == 2
        lambda {
          bob.disconnect bob.contact_for(alice.person) }.should change {
          bob.contacts(true).count }.by(-1)
        bob.aspects.first.contacts(true).count.should == 1
      end

      it 'should remove the contact from all aspects they are in' do
        new_aspect = alice.aspects.create(:name => 'new')
        alice.add_contact_to_aspect( alice.contact_for(bob.person), new_aspect)
        alice.aspects.first.reload.contacts.count.should == 1
        new_aspect.reload.contacts.count.should == 1
        lambda { alice.disconnected_by bob.person }.should change {
          alice.contacts.count }.by(-1)
        alice.aspects.first.reload.contacts.count.should == 0
        new_aspect.reload.contacts.count.should == 0
      end

      context 'with a post' do
        before do
          StatusMessage.delete_all
          @message = alice.post(:status_message, :text => "hi", :to => alice.aspects.first.id)
        end

        it "deletes the disconnected user's posts from visible_posts" do
          bob.reload.raw_visible_posts.include?(@message).should be_true
          bob.disconnect bob.contact_for(alice.person)
          bob.reload.raw_visible_posts.include?(@message).should be_false
        end

      end
    end
  end
end
