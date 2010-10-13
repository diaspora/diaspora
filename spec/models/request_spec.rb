#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Request do
  let(:user) { Factory(:user) }
  let(:aspect) { user.aspect(:name => "dudes") }

  it 'should require a destination and callback url' do
    person_request = Request.new
    person_request.valid?.should be false
    person_request.destination_url = "http://google.com/"
    person_request.callback_url = "http://foob.com/"
    person_request.valid?.should be true
  end

  it 'should generate xml for the User as a Person' do
    request = user.send_friend_request_to Factory(:person), aspect

    xml = request.to_xml.to_s

    xml.should include user.person.diaspora_handle
    xml.should include user.person.url
    xml.should include user.profile.first_name
    xml.should include user.profile.last_name
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

end
