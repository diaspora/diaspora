require File.dirname(__FILE__) + '/../spec_helper'

describe Request do 

  it 'should require a destination and callback url' do
    person_request = Request.new
    person_request.valid?.should be false
    person_request.destination_url = "http://google.com/"
    person_request.callback_url = "http://foob.com/"
    person_request.valid?.should be true
  end

  it 'should generate xml for the User as a Person' do 
    user = Factory.create(:user)

    request = user.send_friend_request_to "http://www.google.com/"

    xml = request.to_xml.to_s

    xml.include?(user.person.email).should be true
    xml.include?(user.url).should be true
    xml.include?(user.profile.first_name).should be true
    xml.include?(user.profile.last_name).should be true
  end

  it 'should allow me to see only friend requests sent to me' do 
    user = Factory.create(:user)
    remote_person = Factory.build(:person, :email => "robert@grimm.com", :url => "http://king.com/")
    
    Request.instantiate(:from => user.person, :to => remote_person.receive_url).save
    Request.instantiate(:from => user.person, :to => remote_person.receive_url).save
    Request.instantiate(:from => user.person, :to => remote_person.receive_url).save
    Request.instantiate(:from => remote_person, :to => user.receive_url).save
      
    Request.for_user(user).all.count.should == 1
  end

end
