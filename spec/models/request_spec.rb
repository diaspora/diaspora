#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Request do
  let(:user) { Factory(:user) }
  let(:user2) { Factory :user}
  let(:person) {Factory :person}
  let(:aspect) { user.aspect(:name => "dudes") }
  let(:request){ user.send_friend_request_to user2.person, aspect }

  it 'should require a destination and callback url' do
    person_request = Request.new
    person_request.valid?.should be false
    person_request.destination_url = "http://google.com/"
    person_request.callback_url = "http://foob.com/"
    person_request.valid?.should be true
  end

  it 'should generate xml for the User as a Person' do

    request = user.send_friend_request_to person, aspect
    xml = request.to_xml.to_s

    xml.should include user.person.diaspora_handle
    xml.should include user.person.url
    xml.should include user.profile.first_name
    xml.should include user.profile.last_name
    xml.should include user.exported_key
  end

  it 'should allow me to see only friend requests sent to me' do
    remote_person = Factory.build(:person, :diaspora_handle => "robert@grimm.com", :url => "http://king.com/")

    Request.instantiate(:into => aspect.id, :from => user.person, :to => remote_person.receive_url).save
    Request.instantiate(:into => aspect.id, :from => user.person, :to => remote_person.receive_url).save
    Request.instantiate(:into => aspect.id, :from => user.person, :to => remote_person.receive_url).save
    Request.instantiate(:into => aspect.id, :from => remote_person, :to => user.receive_url).save

    Request.for_user(user).all.count.should == 1
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

end
