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
      @request = Request.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
    end

    it 'is valid' do
      @request.sender.should == alice.person
      @request.recipient.should   == eve.person
      @request.aspect.should == @aspect
      @request.should be_valid
    end

    it 'is from a person' do
      @request.sender = nil
      @request.should_not be_valid
    end

    it 'is to a person' do
      @request.recipient = nil
      @request.should_not be_valid
    end

    it 'is not necessarily into an aspect' do
      @request.aspect = nil
      @request.should be_valid
    end

    it 'is not from an existing friend' do
      Contact.create(:user => eve, :person => alice.person, :aspects => [eve.aspects.first])
      @request.should_not be_valid
    end

    it 'is not to yourself' do
      @request = Request.diaspora_initialize(:from => alice.person, :to => alice.person, :into => @aspect)
      @request.should_not be_valid
    end
  end

  describe '#notification_type' do
    it 'returns request_accepted' do
      person = FactoryGirl.build:person

      request = Request.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
      alice.contacts.create(:person_id => person.id)

      request.notification_type(alice, person).should == Notifications::StartedSharing
    end
  end

  describe '#subscribers' do
    it 'returns an array with to field on a request' do
      request = Request.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
      request.subscribers(alice).should =~ [eve.person]
    end
  end

  describe '#receive' do
    it 'creates a contact' do
      request = Request.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
      lambda{
        request.receive(eve, alice.person)
      }.should change{
        eve.contacts(true).size
      }.by(1)
    end

    it 'sets mutual if a contact already exists' do
      alice.share_with(eve.person, alice.aspects.first)

      lambda {
        Request.diaspora_initialize(:from => eve.person, :to => alice.person,
                                    :into => eve.aspects.first).receive(alice, eve.person)
      }.should change {
        alice.contacts.find_by_person_id(eve.person.id).mutual?
      }.from(false).to(true)

    end

    it 'sets sharing' do
      Request.diaspora_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.aspects.first).receive(alice, eve.person)
      alice.contact_for(eve.person).should be_sharing
    end
    
    it 'shares back if auto_following is enabled' do
      alice.auto_follow_back = true
      alice.auto_follow_back_aspect = alice.aspects.first
      alice.save
      
      Request.diaspora_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.aspects.first).receive(alice, eve.person)
      
      eve.contact_for(alice.person).should be_sharing
    end
    
    it 'shares not back if auto_following is not enabled' do
      alice.auto_follow_back = false
      alice.auto_follow_back_aspect = alice.aspects.first
      alice.save
      
      Request.diaspora_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.aspects.first).receive(alice, eve.person)
      
      eve.contact_for(alice.person).should be_nil
    end
    
    it 'shares not back if already sharing' do
      alice.auto_follow_back = true
      alice.auto_follow_back_aspect = alice.aspects.first
      alice.save
      
      contact = FactoryGirl.build:contact, :user => alice, :person => eve.person,
                                  :receiving => true, :sharing => false
      contact.save
      
      alice.should_not_receive(:share_with)
      
      Request.diaspora_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.aspects.first).receive(alice, eve.person)
    end
  end

  context 'xml' do
    before do
      @request = Request.diaspora_initialize(:from => alice.person, :to => eve.person, :into => @aspect)
      @xml = @request.to_xml.to_s
    end

    describe 'serialization' do
      it 'produces valid xml' do
        @xml.should include alice.person.diaspora_handle
        @xml.should include eve.person.diaspora_handle
        @xml.should_not include alice.person.exported_key
        @xml.should_not include alice.person.profile.first_name
      end
    end

    context 'marshalling' do
      it 'produces a request object' do
        marshalled = Request.from_xml @xml

        marshalled.sender.should == alice.person
        marshalled.recipient.should == eve.person
        marshalled.aspect.should be_nil
      end
    end
  end
end
