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

  context 'contact requesting' do
    describe  '#receive_contact_request' do
      before do
        @r = Request.diaspora_initialize(:to => alice.person, :from => person)
      end

      it 'creates no contact' do
        lambda {
          received_req = @r.receive(alice, person_one)
        }.should change(Contact, :count).by(1)
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
      before do
        Request.diaspora_initialize(:from => person, :to => alice.person).save
        Request.diaspora_initialize(:from => person_one, :to => alice.person).save

        @received_request = Request.where(:sender_id => person.id, :recipient_id => alice.person.id).first
        @received_request2 = Request.where(:sender_id => person_one.id, :recipient_id => alice.person.id).first
      end

      it 'should ignore a contact request from yourself' do
        request_from_myself = Request.diaspora_initialize(:to => alice.person, :from => alice.person)
        reversed_request = request_from_myself.reverse_for(alice)

        alice.receive_contact_request(reversed_request)
        reversed_request.persisted?.should be false
      end
    end

    describe 'disconnecting' do
      describe '#remove_contact' do
        it 'should remove the contact from all aspects they are in' do
          contact = alice.contact_for(bob.person) 
          new_aspect = alice.aspects.create(:name => 'new')
          alice.add_contact_to_aspect( contact, new_aspect)

          lambda { alice.remove_contact(contact) }.should change(
          contact.aspects, :count).from(2).to(0)
        end

        context 'with a post' do
          it "deletes the disconnected user's posts from visible_posts" do
            StatusMessage.delete_all
            message = alice.post(:status_message, :text => "hi", :to => alice.aspects.first.id)

            bob.reload.raw_visible_posts.include?(message).should be_true
            bob.disconnect bob.contact_for(alice.person)
            bob.reload.raw_visible_posts.include?(message).should be_false
          end
        end
      end

      describe '#disconnected_by' do
        it 'removes a contacts mutual flag' do
          pending 'needs migration'
          alice.share_with(eve.person, alice.aspects.first)

          alice.contacts.where(:person_id => eve.person.id).mutual.should be_true
          eve.disconnected_by(alice.person)
          alice.contacts.where(:person_id => eve.person.id).mutual.should be_false

        end
      end

      describe '#disconnect' do
        it 'disconnects a contact on the same seed' do
          bob.aspects.first.contacts.count.should == 2
          lambda {
            bob.disconnect bob.contact_for(alice.person) }.should change {
            bob.contacts(true).count }.by(-1)
          bob.aspects.first.contacts(true).count.should == 1
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

    it "should mark the corresponding notification as 'read'" do
      notification = Factory.create(:notification, :target => eve.person)

      Notification.where(:target_id => eve.person.id).first.unread.should be_true
      alice.share_with(eve.person, aspect)
      Notification.where(:target_id => eve.person.id).first.unread.should be_false
    end
  end
end
