#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Request do
  before do
    @user    = alice
    @user2   = eve
    @person  = Factory :person
    @aspect  = @user.aspects.first
    @aspect2 = @user2.aspects.first
  end

  describe 'validations' do
    before do
      @request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)
    end
    it 'is valid' do
      @request.sender.should == @user.person
      @request.recipient.should   == @user2.person
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
      Contact.create(:user => @user2, :person => @user.person, :aspects => [@aspect2])
      @request.should_not be_valid
    end
    it 'is not a duplicate of an existing pending request' do
      @request.save
      duplicate_request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)
      duplicate_request.should_not be_valid
    end
    it 'is not to yourself' do
      @request = Request.diaspora_initialize(:from => @user.person, :to => @user.person, :into => @aspect)
      @request.should_not be_valid
    end
  end

  describe '#notification_type' do
    before do
      @request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)
    end

    it 'returns request_accepted' do
      @user.contacts.create(:person_id => @person.id, :pending => true)
      @request.notification_type(@user, @person).should == Notifications::RequestAccepted
    end

    it 'returns new_request' do
      @request.notification_type(@user, @person).should == Notifications::NewRequest
    end
  end

  describe '#subscribers' do
    it 'returns an array with to field on a request' do
      request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)
      request.subscribers(@user).should =~ [@user2.person]
    end
  end

  describe '#receive' do
    it 'calls receive_contact_request on user' do
      request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)

      @user2.should_receive(:receive_contact_request).with(request)
      request.receive(@user2, @user.person)
    end
  end

  context 'xml' do
    before do
      @request = Request.new(:sender => @user.person, :recipient => @user2.person, :aspect => @aspect)
      @xml = @request.to_xml.to_s
    end

    describe 'serialization' do
      it 'produces valid xml' do
        @xml.should include @user.person.diaspora_handle
        @xml.should include @user2.person.diaspora_handle
        @xml.should_not include @user.person.exported_key
        @xml.should_not include @user.person.profile.first_name
      end
    end

    context 'marshalling' do
      it 'produces a request object' do
        marshalled = Request.from_xml @xml

        marshalled.sender.should == @user.person
        marshalled.recipient.should == @user2.person
        marshalled.aspect.should be_nil
      end
    end
  end
end
