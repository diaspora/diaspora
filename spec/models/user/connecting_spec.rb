#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::UserModules::Connecting do

  let(:aspect) { alice.aspects.first }
  let(:aspect1) { alice.aspects.create(:name => 'other') }
  let(:person) { Factory.create(:person) }

  let(:aspect2) { eve.aspects.create(:name => "aspect two") }

  let(:person_one) { Factory.create :person }
  let(:person_two) { Factory.create :person }
  let(:person_three) { Factory.create :person }

  describe '#send_contact_request_to' do
    it 'should not be able to contact request an existing contact' do
      alice.activate_contact(eve.person, aspect1)

      proc {
        alice.send_contact_request_to(eve.person, aspect1)
      }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not be able to contact request no-one' do
      proc {
        alice.send_contact_request_to(nil, aspect)
      }.should raise_error(ActiveRecord::RecordInvalid)
    end
    it 'creates a pending contact' do
      proc {
        alice.send_contact_request_to(eve.person, aspect1)
      }.should change(Contact.unscoped, :count).by(1)
      alice.contact_for(eve.person).pending.should == true
      alice.contact_for(eve.person).should be_pending
    end
    it 'persists no request for requester' do
      proc {
        alice.send_contact_request_to(eve.person, aspect1)
      }.should_not change{Request.where(:recipient_id => alice.person.id).count}
    end
    it 'persists a request for the recipient' do
      alice.send_contact_request_to(eve.person, aspect1)
      eve.request_from(alice.person).should_not be_nil
    end
  end

  context 'contact requesting' do
    describe  '#receive_contact_request' do
      before do
        @r = Request.diaspora_initialize(:to => alice.person, :from => person)
      end

      it 'adds a request to pending if it was not sent by user' do
        alice.receive_contact_request(@r)
        Request.where(:recipient_id => alice.person.id).all.should include @r
      end

      it 'creates no contact' do
        lambda {
          received_req = @r.receive(alice, person_one)
        }.should_not change(Contact, :count)
      end
    end

    describe '#receive_request_acceptance' do
      before do
        @original_request = alice.send_contact_request_to(eve.person, aspect)
        @acceptance = @original_request.reverse_for(eve)
      end
      it 'connects to the acceptor' do
        alice.receive_contact_request(@acceptance)
        alice.contact_for(eve.person).should_not be_nil
      end
      it 'deletes the acceptance' do
        alice.receive_contact_request(@acceptance)
        Request.where(:sender_id => eve.person.id, :recipient_id => alice.person.id).should be_empty
      end
    end

    context 'received a contact request' do
      let(:request_for_user) {Request.diaspora_initialize(:to => alice.person, :from => person)}
      let(:request2_for_user) {Request.diaspora_initialize(:to => alice.person, :from => person_one)}
      let(:request_from_myself) {Request.diaspora_initialize(:to => alice.person, :from => alice.person)}
      before do
        Request.diaspora_initialize(:from => person, :to => alice.person).save
        Request.diaspora_initialize(:from => person_one, :to => alice.person).save

        @received_request = Request.where(:sender_id => person.id, :recipient_id => alice.person.id).first
        @received_request2 = Request.where(:sender_id => person_one.id, :recipient_id => alice.person.id).first
      end

      it "should delete an accepted contact request" do
        proc {
          alice.accept_contact_request(@received_request, aspect)
        }.should change(Request, :count ).by(-1)
      end

      it "should mark the corresponding notification as 'read'" do
        notification = Factory.create(:notification, :target => @received_request)

        Notification.where(:target_id=>@received_request.id).first.unread.should be_true
        alice.accept_contact_request(@received_request, aspect)
        Notification.where(:target_id=>@received_request.id).first.unread.should be_false
      end

      it 'should be able to ignore a pending contact request' do
        proc { alice.ignore_contact_request(@received_request.id)
        }.should change(Request, :count ).by(-1)
      end

      it 'should ignore a contact request from yourself' do
        reversed_request = request_from_myself.reverse_for(alice)

        alice.receive_contact_request(reversed_request)
        reversed_request.persisted?.should be false
      end
    end

    describe 'multiple users accepting/rejecting the same person' do

      before do
        @request1 = Request.diaspora_initialize(:to => alice.person, :from => person_one)
        @request2 = Request.diaspora_initialize(:to => eve.person, :from => person_one)
        @request3 =  Request.diaspora_initialize(:to => eve.person, :from => alice.person)

        @req1_xml = @request1.to_diaspora_xml
        @req2_xml = @request2.to_diaspora_xml
        @req3_xml = @request3.to_diaspora_xml

        @request1.destroy
        @request2.destroy
        @request3.destroy
      end

      context 'request from one remote person to one local user' do
        before do
          zord = Postzord::Receiver.new(alice, :person => alice.person)
          @received_request = zord.parse_and_receive(@req3_xml)
          @received_request.reload
        end

        it 'should connect the user other user on the same pod' do
          proc {
            eve.accept_contact_request(@received_request, aspect2)
          }.should_not change(Person, :count)
          eve.contact_for(alice.person).should_not be_nil
        end

        it 'should not delete the ignored user on the same pod' do

          proc {
            eve.ignore_contact_request(@received_request.id)
          }.should_not change(Person, :count)
          eve.contact_for(alice.person).should be_nil
        end
      end

      context 'Two users receiving requests from one person' do
        before do
          zord1 = Postzord::Receiver.new(alice, :person => person_one)
          zord2 = Postzord::Receiver.new(alice, :person => person_one)

          @req_to_user = zord1.parse_and_receive(@req1_xml)
          @req_to_eve = zord2.parse_and_receive(@req2_xml)
        end

        describe '#accept_contact_request' do
          it 'should both users should connect the same person' do
            alice.accept_contact_request @req_to_user, aspect
            alice.contact_for(person_one).should_not be_nil

            eve.accept_contact_request @req_to_eve, aspect2
            eve.contact_for(person_one).should_not be_nil
          end

          it 'should keep the person around if one of the users rejects him' do
            alice.accept_contact_request @req_to_user, aspect
            alice.contact_for(person_one).should_not be_nil

            eve.ignore_contact_request @req_to_eve.id
            eve.contact_for(person_one).should be_nil
          end
        end


        it 'should keep the person around if the users ignores them' do
          alice.ignore_contact_request Request.where(:recipient_id => alice.person.id).first.id
          alice.contact_for(person_one).should be_nil

          eve.ignore_contact_request Request.where(:recipient_id => eve.person.id).first.id
          eve.contact_for(person_one).should be_nil
        end
      end


    end

    describe 'a user accepting & rejecting multiple people' do
      before do
        request = Request.diaspora_initialize(:to => alice.person, :from => person_one)
        @received_request = request.receive(alice, person_one)
      end
      describe '#accept_contact_request' do
        it "deletes the received request" do
          lambda {
            alice.accept_contact_request(@received_request, aspect)
          }.should change(Request, :count).by(-1)
        end
        it "creates a new contact" do
          lambda {
            alice.accept_contact_request(@received_request, aspect)
          }.should change(Contact, :count).by(1)
          alice.contact_for(person_one).should_not be_nil
        end
      end
      describe '#ignore_contact_request' do
        it "removes the request" do
          lambda {
            alice.ignore_contact_request(@received_request.id)
          }.should change(Request, :count).by(-1)
        end
        it "creates no new contact" do
          lambda {
            alice.ignore_contact_request(@received_request)
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

  describe '#share_with' do
    it 'finds or creates a contact' do
      lambda {
        alice.share_with(eve.person, alice.aspects.first)
      }.should change(alice.contacts, :count).by(1)
    end

    it 'adds a contact to an aspect' do
      contact = alice.contacts.create(:person => eve.person)
      alice.contacts.stub!(:find_or_initialize_by_person_id).and_return(contact)

      lambda {
        alice.share_with(eve.person, alice.aspects.first)
      }.should change(contact.aspects, :count).by(1)
    end

    it 'dispatches a request' do
      contact = alice.contacts.new(:person => eve.person)
      alice.contacts.stub!(:find_or_initialize_by_person_id).and_return(contact)

      contact.should_receive(:dispatch_request)
      alice.share_with(eve.person, alice.aspects.first)
    end

    it 'does not dispatch a request' do
      contact = alice.contacts.create(:person => eve.person)
      alice.contacts.stub!(:find_or_initialize_by_person_id).and_return(contact)

      contact.should_not_receive(:dispatch_request)
      alice.share_with(eve.person, alice.aspects.first)
    end
  end
end
