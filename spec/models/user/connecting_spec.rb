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
      it 'creates a contact' do
        r = Request.diaspora_initialize(:to => alice.person, :from => person)

        lambda {
          received_req = r.receive(alice, person_one)
        }.should change(Contact, :count).by(1)
      end
    end

    describe '#receive_contact_request' do
      before do
        @request = Request.new(:sender => eve.person, :recipient => alice.person)
      end
      it 'sets mutual on an existing contact' do
        alice.share_with(eve.person, aspect)
        lambda{
          alice.receive_contact_request(@request)
        }.should change{
          alice.contacts.find_by_person_id(eve.person.id).mutual
        }.from(false).to(true)
      end

      it 'does not set mutual' do
        alice.receive_contact_request(@request)
        alice.contacts.find_by_person_id(eve.person.id).should_not be_mutual
      end
      
      it 'doesnt set mutual on a contact' do
        pending
        alice.receive_contact_request(@acceptance)
        Request.where(:sender_id => eve.person.id, :recipient_id => alice.person.id).should be_empty
      end
    end

    context 'received a contact request' do
      it 'should ignore a contact request from yourself' do
        request_from_myself = Request.diaspora_initialize(:to => alice.person, :from => alice.person)
        reversed_request = request_from_myself.reverse_for(alice)

        alice.receive_contact_request(reversed_request)
        reversed_request.persisted?.should be false
      end
    end

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

        it 'removes a contacts mutual flag' do
          lambda{
            bob.remove_contact(bob.contact_for(alice.person))
          }.should change {
            bob.contacts.find_by_person_id(alice.person.id).mutual
          }.from(true).to(false)
        end

        it "deletes the disconnected user's posts from visible_posts" do
          StatusMessage.delete_all
          message = alice.post(:status_message, :text => "hi", :to => alice.aspects.first.id)

          bob.reload.raw_visible_posts.should include(message)
          bob.disconnect bob.contact_for(alice.person)
          bob.reload.raw_visible_posts.should_not include(message)
        end

        it 'should remove the contact from all aspects they are in' do
          contact = alice.contact_for(bob.person) 
          new_aspect = alice.aspects.create(:name => 'new')
          alice.add_contact_to_aspect(contact, new_aspect)

          lambda {
            alice.remove_contact(contact)
          }.should change(contact.aspects(true), :count).from(2).to(0)
        end
      end

      describe '#disconnected_by' do
        it 'calls remove contact' do
          bob.should_receive(:remove_contact).with(bob.contact_for(alice.person))
          bob.disconnected_by(alice.person)
        end
      end

      describe '#disconnect' do
        it 'calls remove contact' do
          contact = bob.contact_for(alice.person)

          bob.should_receive(:remove_contact).with(contact)
          bob.disconnect contact
        end

        it 'dispatches a retraction' do
          p = mock()
          Postzord::Dispatch.should_receive(:new).and_return(p)
          p.should_receive(:post)

          bob.disconnect bob.contact_for(eve.person)
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
