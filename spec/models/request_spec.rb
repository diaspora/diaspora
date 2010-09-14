#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



require File.dirname(__FILE__) + '/../spec_helper'

describe Request do 
  before do
    @user = Factory.create(:user)
    @aspect = @user.aspect(:name => "dudes")
  end
  it 'should require a destination and callback url' do
    person_request = Request.new
    person_request.valid?.should be false
    person_request.destination_url = "http://google.com/"
    person_request.callback_url = "http://foob.com/"
    person_request.valid?.should be true
  end

  it 'should generate xml for the User as a Person' do 
    request = @user.send_friend_request_to Factory.create(:person), @aspect

    xml = request.to_xml.to_s

    xml.include?(@user.person.email).should be true
    xml.include?(@user.url).should be true
    xml.include?(@user.profile.first_name).should be true
    xml.include?(@user.profile.last_name).should be true
  end

  it 'should allow me to see only friend requests sent to me' do 
    remote_person = Factory.build(:person, :email => "robert@grimm.com", :url => "http://king.com/")
    
    Request.instantiate(:into => @aspect.id, :from => @user.person, :to => remote_person.receive_url).save
    Request.instantiate(:into => @aspect.id, :from => @user.person, :to => remote_person.receive_url).save
    Request.instantiate(:into => @aspect.id, :from => @user.person, :to => remote_person.receive_url).save
    Request.instantiate(:into => @aspect.id, :from => remote_person, :to => @user.receive_url).save
      
    Request.for_user(@user).all.count.should == 1
  end

end
