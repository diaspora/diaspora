#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Request do
  let(:user)   { make_user }
  let(:user2)  { make_user }
  let(:person) { Factory :person }
  let(:aspect) { user.aspects.create(:name => "dudes") }
  let(:request){ user.send_contact_request_to user2.person, aspect }

  describe 'validations' do
    before do
      @request = Request.instantiate(:from => user.person, :to => user2.person, :into => aspect) 
    end
    it 'is valid' do
      @request.should be_valid
      @request.from.should == user.person
      @request.to.should   == user2.person
      @request.into.should == aspect
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
    it 'is not a duplicate of an existing pending request' do
      request
      @request.should_not be_valid
    end
    it 'is not to an existing friend' do
      connect_users(user, aspect, user2, user2.aspects.create(:name => 'new aspect'))
      @request.should_not be_valid
    end
  end

  describe '#request_from_me' do
    it 'recognizes requests from me' do
      user.request_from_me?(request).should be_true
    end

    it 'recognized when a request is not from me' do 
      user2.request_from_me?(request).should be_false
    end
  end

  context 'quering request through user' do
    it 'finds requests for that user' do
      request
      user2.reload
      user2.requests_for_me.detect{|r| r.from == user.person}.should_not be_nil
    end
  end

  describe '#original_request' do
    it 'returns nil on a request from me' do
      request
      user.original_request(request).should be_nil
    end
    it 'returns the original request on a response to a request from me' do
      new_request = request.reverse_for(user2)
      user.original_request(new_request).should == request
    end
  end

  describe 'xml' do
    before do
      @request = Request.new(:from => user.person, :to => user2.person, :into => aspect) 
      @xml = @request.to_xml.to_s
    end
    describe 'serialization' do
      it 'should not generate xml for the User as a Person' do
        @xml.should_not include user.person.profile.first_name
      end

      it 'should serialize the handle and not the sender' do
        @xml.should include user.person.diaspora_handle
      end

      it 'serializes the intended recipient handle' do
        @xml.should include user2.person.diaspora_handle
      end

      it 'should not serialize the exported key' do
        @xml.should_not include user.person.exported_key
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
        @marshalled.from.should == user.person
      end
      it 'marshals the recipient' do
        @marshalled.to.should == user2.person
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
        @marshalled.from.should == user.person
      end
      it 'marshals the recipient' do
        @marshalled.to.should == user2.person
      end
      it 'knows nothing about the aspect' do
        @marshalled.into.should be_nil
      end
    end
  end
  
  context 'mailers' do
    context 'sugar around contacts' do
      before do
        Request.should_receive(:async).and_return(Request)
        @mock_request = mock()
        @mock_request.should_receive(:commit!)
      end
      
      describe '.send_request_accepted' do
        it 'should make a call to push to the queue' do
          Request.should_receive(:send_request_accepted!).with(user.id, person.id, aspect.id).and_return(@mock_request)
          Request.send_request_accepted(user, person, aspect)
        end
      end
    
      describe '.send_new_request' do
        it 'should make a call to push to the queue' do
          Request.should_receive(:send_new_request!).with(user.id, person.id).and_return(@mock_request)
          Request.send_new_request(user, person)
        end
      end
    end
    
    context 'actual calls to mailer' do
      before do
        @mock_mail = mock()
        @mock_mail.should_receive(:deliver)
      end
      describe '.send_request_accepted!' do
        it 'should deliver the message' do
          Notifier.should_receive(:request_accepted).and_return(@mock_mail)
          Request.send_request_accepted!(user.id, person.id, aspect.id)
        end
      end
    
      describe '.send_new_request' do
        it 'should deliver the message' do
          Notifier.should_receive(:new_request).and_return(@mock_mail)
          Request.send_new_request!(user.id, person.id)
        end
      end
    end
  end
end
