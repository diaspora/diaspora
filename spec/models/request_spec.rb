require 'spec_helper'

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
    request = Request.new(:url => "http://www.google.com/", :person => user)

    xml = request.to_xml.to_s
    xml.include?(user.email).should be true
    xml.include?(user.url).should be true
    xml.include?(user.profile.first_name).should be true
    xml.include?(user.profile.last_name).should be true
  end


  it "should should activate a user" do
    remote_person = Factory.create(:person, :email => "robert@grimm.com", :url => "http://king.com/")
    f = Request.create(:destination_url => remote_person.url, :person => remote_person)
    f.activate_friend
    Person.where(:id => remote_person.id).first.active.should be true
  end


  it 'should allow me to see only friend requests sent to me' do 
    user = Factory.create(:user)
    remote_person = Factory.build(:user, :email => "robert@grimm.com", :url => "http://king.com/")
    
    Request.instantiate(:from => user, :to => remote_person.url).save
    Request.instantiate(:from => user, :to => remote_person.url).save
    Request.instantiate(:from => user, :to => remote_person.url).save
    Request.instantiate(:from => remote_person, :to => user.url).save
      
    Request.for_user(user).all.count.should == 1
  end

  it 'should allow me to see only friend requests sent by me' do 
    user = Factory.create(:user)
    remote_person = Factory.build(:user, :email => "robert@grimm.com", :url => "http://king.com/")

    Request.instantiate(:from => user, :to => remote_person.url).save
    Request.instantiate(:from => user, :to => remote_person.url).save
    Request.instantiate(:from => user, :to => remote_person.url).save
    Request.instantiate(:from => remote_person, :to => user.url).save

    Request.from_user(user).all.count.should == 3
  end

end
