#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User::Connecting do

  let(:aspect) { alice.aspects.first }
  let(:aspect1) { alice.aspects.create(:name => 'other') }
  let(:person) { FactoryGirl.create(:person) }

  let(:aspect2) { eve.aspects.create(:name => "aspect two") }

  let(:person_one) { FactoryGirl.create :person }
  let(:person_two) { FactoryGirl.create :person }
  let(:person_three) { FactoryGirl.create :person }

  describe 'disconnecting' do
    describe '#remove_contact' do
      it 'removed non mutual contacts' do
        alice.share_with(eve.person, alice.aspects.first)
        lambda {
          alice.remove_contact alice.contact_for(eve.person)
        }.should change {
          alice.contacts(true).count
        }.by(-1)
      end

      it 'removes a contacts receiving flag' do
        bob.contacts.find_by_person_id(alice.person.id).should be_receiving
        bob.remove_contact(bob.contact_for(alice.person))
        bob.contacts(true).find_by_person_id(alice.person.id).should_not be_receiving
      end
    end

    describe '#disconnected_by' do
      it 'calls remove contact' do
        bob.should_receive(:remove_contact).with(bob.contact_for(alice.person))
        bob.disconnected_by(alice.person)
      end

      it 'removes notitications' do
        alice.share_with(eve.person, alice.aspects.first)
        Notifications::StartedSharing.where(:recipient_id => eve.id).first.should_not be_nil
        eve.disconnected_by(alice.person)
        Notifications::StartedSharing.where(:recipient_id => eve.id).first.should be_nil
      end
    end

    describe '#disconnect' do
      it 'calls remove contact' do
        contact = bob.contact_for(alice.person)

        bob.should_receive(:remove_contact).with(contact, {})
        bob.disconnect(contact)
      end

      it 'dispatches a retraction' do
        p = mock()
        Postzord::Dispatcher.should_receive(:build).and_return(p)
        p.should_receive(:post)

        bob.disconnect bob.contact_for(eve.person)
      end

      it 'should remove the contact from all aspects they are in' do
        contact = alice.contact_for(bob.person)
        new_aspect = alice.aspects.create(:name => 'new')
        alice.add_contact_to_aspect(contact, new_aspect)

        lambda {
          alice.disconnect(contact)
        }.should change(contact.aspects(true), :count).from(2).to(0)
      end
    end
  end

  describe '#register_share_visibilities' do
    it 'creates post visibilites for up to 100 posts' do
      Post.stub_chain(:where, :limit).and_return([FactoryGirl.create(:status_message)])
      c = Contact.create!(:user_id => alice.id, :person_id => eve.person.id)
      expect{
        alice.register_share_visibilities(c)
      }.to change(ShareVisibility, :count).by(1)
    end
  end

  describe '#share_with' do
    it 'finds or creates a contact' do
      lambda {
        alice.share_with(eve.person, alice.aspects.first)
      }.should change(alice.contacts, :count).by(1)
    end

    it 'does not set mutual on intial share request' do
      alice.share_with(eve.person, alice.aspects.first)
      alice.contacts.find_by_person_id(eve.person.id).should_not be_mutual
    end

    it 'does set mutual on share-back request' do
      eve.share_with(alice.person, eve.aspects.first)
      alice.share_with(eve.person, alice.aspects.first)

      alice.contacts.find_by_person_id(eve.person.id).should be_mutual
    end

    it 'adds a contact to an aspect' do
      contact = alice.contacts.create(:person => eve.person)
      alice.contacts.stub!(:find_or_initialize_by_person_id).and_return(contact)

      lambda {
        alice.share_with(eve.person, alice.aspects.first)
      }.should change(contact.aspects, :count).by(1)
    end

    it 'calls #register_share_visibilities with a contact' do
      eve.should_receive(:register_share_visibilities)
      eve.share_with(alice.person, eve.aspects.first)
    end

    context 'dispatching' do
      it 'dispatches a request on initial request' do
        contact = alice.contacts.new(:person => eve.person)
        alice.contacts.stub!(:find_or_initialize_by_person_id).and_return(contact)

        contact.should_receive(:dispatch_request)
        alice.share_with(eve.person, alice.aspects.first)
      end

      it 'dispatches a request on a share-back' do
        eve.share_with(alice.person, eve.aspects.first)

        contact = alice.contact_for(eve.person)
        alice.contacts.stub!(:find_or_initialize_by_person_id).and_return(contact)

        contact.should_receive(:dispatch_request)
        alice.share_with(eve.person, alice.aspects.first)
      end

      it 'does not dispatch a request if contact already marked as receiving' do
        a2 = alice.aspects.create(:name => "two")

        contact = alice.contacts.create(:person => eve.person, :receiving => true)
        alice.contacts.stub!(:find_or_initialize_by_person_id).and_return(contact)

        contact.should_not_receive(:dispatch_request)
        alice.share_with(eve.person, a2)
      end
    end

    it 'sets receiving' do
      alice.share_with(eve.person, alice.aspects.first)
      alice.contact_for(eve.person).should be_receiving
    end

    it "should mark the corresponding notification as 'read'" do
      notification = FactoryGirl.create(:notification, :target => eve.person)

      Notification.where(:target_id => eve.person.id).first.unread.should be_true
      alice.share_with(eve.person, aspect)
      Notification.where(:target_id => eve.person.id).first.unread.should be_false
    end
  end
end
