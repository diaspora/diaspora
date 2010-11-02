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
      deliverable = Object.new
      deliverable.stub!(:deliver)
      Notifier.stub!(:new_request).and_return(deliverable)

      user2.receive_salmon(user.salmon(request).xml_for(user2.person))
      user2.reload
      user2.request_from_me?(request).should == false
    end
  end

  context 'quering request through user' do
    it 'finds requests for that user' do
      deliverable = Object.new
      deliverable.stub!(:deliver)
      Notifier.stub!(:new_request).and_return(deliverable)

      user2.receive_salmon(user.salmon(request).xml_for(user2.person))
      user2.reload
      user2.requests_for_me.include?(request).should == true
    end
  end

  describe 'serialization' do
    it 'should not generate xml for the User as a Person' do
      request = user.send_friend_request_to person, aspect
      xml = request.to_xml.to_s

      xml.should_not include user.person.profile.first_name
    end

    it 'should serialize the handle and not the sender' do
      request = user.send_friend_request_to person, aspect
      xml = request.to_xml.to_s

      xml.should include user.person.diaspora_handle
    end

    it 'should not serialize the exported key' do
      request = user.send_friend_request_to person, aspect
      xml = request.to_xml.to_s

      xml.should_not include user.person.exported_key
    end

  end

end
