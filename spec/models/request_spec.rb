#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Request do
  let(:user) { make_user }
  let(:user2) { make_user}
  let(:person) {Factory :person}
  let(:aspect) { user.aspects.create(:name => "dudes") }
  let(:request){ user.send_friend_request_to user2.person, aspect }

  it 'should require a destination and callback url' do
    person_request = Request.new
    person_request.valid?.should be false
    person_request.destination_url = "http://google.com/"
    person_request.callback_url = "http://foob.com/"
    person_request.valid?.should be true
  end


  it 'should strip the destination url' do
    person_request = Request.new
    person_request.destination_url = "   http://google.com/   "
    person_request.send(:clean_link)
    person_request.destination_url.should == "http://google.com/"
  end

  describe '#request_from_me' do
    it 'recognizes requests from me' do
      request
      user.reload
      user.request_from_me?(request).should be true
    end

    it 'recognized when a request is not from me' do 
      user2.receive_salmon(user.salmon(request).xml_for(user2.person))
      user2.reload
      user2.request_from_me?(request).should == false
    end
  end

  context 'quering request through user' do
    it 'finds requests for that user' do
      len = user2.requests_for_me.size
      user2.receive_salmon(user.salmon(request).xml_for(user2.person))
      user2.reload.requests_for_me.size.should == len + 1
    end
  end

  describe 'serialization' do
    before do
      @request = user.send_friend_request_to person, aspect
      @xml = @request.to_xml.to_s
    end
    it 'should not generate xml for the User as a Person' do
      @xml.should_not include user.person.profile.first_name
    end

    it 'should serialize the handle and not the sender' do
      @xml.should include user.person.diaspora_handle
    end

    it 'should not serialize the exported key' do
      @xml.should_not include user.person.exported_key
    end

    it 'does not serialize the id' do
      @xml.should_not include @request.id.to_s
    end
  end
  
  context 'mailers' do
    context 'suger around friends' do
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