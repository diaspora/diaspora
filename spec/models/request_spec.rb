#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Request do
  before do
    @user    = make_user
    @user2   = make_user
    @person  = Factory :person
    @aspect  = @user.aspects.create(:name => "dudes")
    @aspect2 = @user2.aspects.create(:name => "Snoozers")
  end

  describe 'validations' do
    before do
      @request = Request.instantiate(:from => @user.person, :to => @user2.person, :into => @aspect)
    end
    it 'is valid' do
      @request.should be_valid
      @request.from.should == @user.person
      @request.to.should   == @user2.person
      @request.into.should == @aspect
    end
    it 'is from a person' do
      @request.from = nil
      @request.should_not be_valid
    end
    it 'is to a person' do
      @request.to = nil
      @request.should_not be_valid
    end
    it 'is not necessarily into an aspect' do
      @request.into = nil
      @request.should be_valid
    end
    it 'is not from an existing friend' do
      Contact.create(:user => @user2, :person => @user.person, :aspects => [@aspect2])
      @request.should_not be_valid
    end
    it 'is not a duplicate of an existing pending request' do
      @request.save
      duplicate_request = Request.instantiate(:from => @user.person, :to => @user2.person, :into => @aspect)
      duplicate_request.should_not be_valid
    end
    it 'is not to yourself' do
      @request = Request.instantiate(:from => @user.person, :to => @user.person, :into => @aspect)
      @request.should_not be_valid
    end
  end

  describe 'scopes' do
    before do
      @request = Request.instantiate(:from => @user.person, :to => @user2.person, :into => @aspect)
      @request.save
    end
    describe '.from' do
      it 'returns requests from a person' do
        query = Request.from(@user.person)
        query.first.should == @request
      end

      it 'returns requests from a user' do
        query = Request.from(@user)
        query.first.should == @request
      end
    end
    describe '.to' do
      it 'returns requests to a person' do
        query = Request.to(@user2.person)
        query.first.should == @request
      end
      it 'returns requests to a user' do
        query = Request.to(@user2)
        query.first.should == @request
      end
    end
    it 'chains' do
      Request.from(@user).to(@user2.person).first.should == @request
    end
  end

  describe '#notification_type' do
    before do
      @request = Request.instantiate(:from => @user.person, :to => @user2.person, :into => @aspect)    
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
      request = Request.instantiate(:from => @user.person, :to => @user2.person, :into => @aspect)    
      request.subscribers(@user).should =~ [@user2.person]
    end
  end

  describe '.hashes_for_person' do
    before do
      @user = make_user
      @user2 = make_user
      @user2.send_contact_request_to @user.person, @user2.aspects.create(:name => "hi")
      @user.reload
      @user2.reload
      @hashes = Request.hashes_for_person(@user.person)
      @hash = @hashes.first
    end
    it 'gives back requests' do
      @hash[:request].should == Request.from(@user2).to(@user).first
    end
    it 'gives back people' do
      @hash[:sender].should == @user2.person
    end
    it 'does not retrieve keys' do
      @hash[:sender].serialized_public_key.should be_nil
    end
  end


  describe '#receive' do
  end

  
  describe 'xml' do
    before do
      @request = Request.new(:from => @user.person, :to => @user2.person, :into => @aspect)
      @xml = @request.to_xml.to_s
    end
    describe 'serialization' do
      it 'should not generate xml for the User as a Person' do
        @xml.should_not include @user.person.profile.first_name
      end

      it 'should serialize the handle and not the sender' do
        @xml.should include @user.person.diaspora_handle
      end

      it 'serializes the intended recipient handle' do
        @xml.should include @user2.person.diaspora_handle
      end

      it 'should not serialize the exported key' do
        @xml.should_not include @user.person.exported_key
      end

      it 'does not serialize the id' do
        @xml.should_not include @request.id.to_s
      end
    end

    describe 'marshalling' do
      before do
        @marshalled = Request.from_xml @xml
      end
      it 'marshals the sender' do
        @marshalled.from.should == @user.person
      end
      it 'marshals the recipient' do
        @marshalled.to.should == @user2.person
      end
      it 'knows nothing about the aspect' do
        @marshalled.into.should be_nil
      end
    end
    describe 'marshalling with diaspora wrapper' do
      before do
        @d_xml = @request.to_diaspora_xml
        @marshalled = Diaspora::Parser.from_xml @d_xml
      end
      it 'marshals the sender' do
        @marshalled.from.should == @user.person
      end
      it 'marshals the recipient' do
        @marshalled.to.should == @user2.person
      end
      it 'knows nothing about the aspect' do
        @marshalled.into.should be_nil
      end
    end
  end
end
