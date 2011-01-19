#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Request do
  before do
    @user    = Factory.create(:user)
    @user2   = Factory.create(:user)
    @person  = Factory :person
    @aspect  = @user.aspects.create(:name => "dudes")
    @aspect2 = @user2.aspects.create(:name => "Snoozers")
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
    it "returns 'request_accepted' if there is a pending contact" do
      Contact.create(:user_id => @user.id, :person_id => @person.id)
      @request.notification_type(@user, @person).should  == "request_accepted"
    end

    it 'returns new_request if there is not a pending contact' do
      @request.notification_type(@user, @person).should  == "new_request"
    end
  end

  describe '#subscribers' do
    it 'returns an array with to field on a request' do
      request = Request.diaspora_initialize(:from => @user.person, :to => @user2.person, :into => @aspect)
      request.subscribers(@user).should =~ [@user2.person]
    end
  end

  describe 'xml' do
    before do
      @request = Request.new(:sender => @user.person, :recipient => @user2.person, :aspect => @aspect)
      @xml = @request.to_xml.to_s
    end
    describe 'serialization' do
      it 'does not generate xml for the User as a Person' do
        @xml.should_not include @user.person.profile.first_name
      end

      it 'serializes the handle and not the sender' do
        @xml.should include @user.person.diaspora_handle
      end

      it 'serializes the intended recipient handle' do
        @xml.should include @user2.person.diaspora_handle
      end

      it 'does not serialize the exported key' do
        @xml.should_not include @user.person.exported_key
      end
    end

    describe 'marshalling' do
      before do
        @marshalled = Request.from_xml @xml
      end
      it 'marshals the sender' do
        @marshalled.sender.should == @user.person
      end
      it 'marshals the recipient' do
        @marshalled.recipient.should == @user2.person
      end
      it 'knows nothing about the aspect' do
        @marshalled.aspect.should be_nil
      end
    end
    describe 'marshalling with diaspora wrapper' do
      before do
        @d_xml = @request.to_diaspora_xml
        @marshalled = Diaspora::Parser.from_xml @d_xml
      end
      it 'marshals the sender' do
        @marshalled.sender.should == @user.person
      end
      it 'marshals the recipient' do
        @marshalled.recipient.should == @user2.person
      end
      it 'knows nothing about the aspect' do
        @marshalled.aspect.should be_nil
      end
    end
  end
end
