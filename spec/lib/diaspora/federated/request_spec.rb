#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Request do
  before do
    @aspect = alice.aspects.first
  end

  describe 'validations' do
    before do
      @request = described_class.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
    end

    it 'is valid' do
      expect(@request.sender).to eq(alice.person)
      expect(@request.recipient).to   eq(eve.person)
      expect(@request.aspect).to eq(@aspect)
      expect(@request).to be_valid
    end

    it 'is from a person' do
      @request.sender = nil
      expect(@request).not_to be_valid
    end

    it 'is to a person' do
      @request.recipient = nil
      expect(@request).not_to be_valid
    end

    it 'is not necessarily into an aspect' do
      @request.aspect = nil
      expect(@request).to be_valid
    end

    it 'is not from an existing friend' do
      Contact.create(:user => eve, :person => alice.person, :aspects => [eve.aspects.first])
      expect(@request).not_to be_valid
    end

    it 'is not to yourself' do
      @request = described_class.diaspora_initialize(:from => alice.person, :to => alice.person, :into => @aspect)
      expect(@request).not_to be_valid
    end
  end

  describe '#notification_type' do
    it 'returns request_accepted' do
      person = FactoryGirl.build:person

      request = described_class.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
      alice.contacts.create(:person_id => person.id)

      expect(request.notification_type(alice, person)).to eq(Notifications::StartedSharing)
    end
  end

  describe '#subscribers' do
    it 'returns an array with to field on a request' do
      request = described_class.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
      expect(request.subscribers(alice)).to match_array([eve.person])
    end
  end

  describe '#receive' do
    it 'creates a contact' do
      request = described_class.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
      expect{
        request.receive(eve, alice.person)
      }.to change{
        eve.contacts(true).size
      }.by(1)
    end

    it 'sets mutual if a contact already exists' do
      alice.share_with(eve.person, alice.aspects.first)

      expect {
        described_class.diaspora_initialize(:from => eve.person, :to => alice.person,
                                    :into => eve.aspects.first).receive(alice, eve.person)
      }.to change {
        alice.contacts.find_by_person_id(eve.person.id).mutual?
      }.from(false).to(true)

    end

    it 'sets sharing' do
      described_class.diaspora_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.aspects.first).receive(alice, eve.person)
      expect(alice.contact_for(eve.person)).to be_sharing
    end
    
    it 'shares back if auto_following is enabled' do
      alice.auto_follow_back = true
      alice.auto_follow_back_aspect = alice.aspects.first
      alice.save
      
      described_class.diaspora_initialize(:from => eve.person, :to => alice.person,
                                          :into => eve.aspects.first).receive(alice, eve.person)
      
      expect(eve.contact_for( alice.person )).to be_sharing
    end
    
    it 'shares not back if auto_following is not enabled' do
      alice.auto_follow_back = false
      alice.auto_follow_back_aspect = alice.aspects.first
      alice.save
      
      described_class.diaspora_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.aspects.first).receive(alice, eve.person)
      
      expect(eve.contact_for(alice.person)).to be_nil
    end
    
    it 'shares not back if already sharing' do
      alice.auto_follow_back = true
      alice.auto_follow_back_aspect = alice.aspects.first
      alice.save
      
      contact = FactoryGirl.build:contact, :user => alice, :person => eve.person,
                                  :receiving => true, :sharing => false
      contact.save
      
      expect(alice).not_to receive(:share_with)
      
      described_class.diaspora_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.aspects.first).receive(alice, eve.person)
    end
  end

  context 'xml' do
    before do
      @request = described_class.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
      @xml = @request.to_xml.to_s
    end

    describe 'serialization' do
      it 'produces valid xml' do
        expect(@xml).to include alice.person.diaspora_handle
        expect(@xml).to include eve.person.diaspora_handle
        expect(@xml).not_to include alice.person.exported_key
        expect(@xml).not_to include alice.person.profile.first_name
      end
    end

    context 'marshalling' do
      it 'produces a request object' do
        marshalled = described_class.from_xml @xml

        expect(marshalled.sender).to eq(alice.person)
        expect(marshalled.recipient).to eq(eve.person)
        expect(marshalled.aspect).to be_nil
      end
    end
  end
end
