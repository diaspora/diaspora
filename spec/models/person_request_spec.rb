require 'spec_helper'

describe PersonRequest do 

  it 'should require a url' do
    person_request = PersonRequest.new
    person_request.valid?.should be false
    person_request.destination_url = "http://google.com/"
    person_request.valid?.should be true
  end

  it 'should generate xml for the User as a Person' do 
    user = Factory.create(:user)
    request = PersonRequest.new(:url => "http://www.google.com/", :person => user)

    xml = request.to_xml.to_s
    xml.include?(user.email).should be true
    xml.include?(user.url).should be true
    xml.include?(user.profile.first_name).should be true
    xml.include?(user.profile.last_name).should be true
  end

  it 'should be sent to the url upon for action' do
    PersonRequest.send(:class_variable_get, :@@queue).should_receive(:add_post_request)
    Factory.create(:user)
    PersonRequest.send_to("http://www.google.com")
  end

  it "should activate a person if it exists on creation of a request for that url" do
    user = Factory.create(:user)
    person = Factory.create(:person, :url => "http://123google.com/")
    PersonRequest.send_to(person.url)
    Person.where(:url => person.url).first.active.should be true
  end

  it "should send a person request to specified url" do
    Factory.create(:user)
    PersonRequest.send(:class_variable_get, :@@queue).should_receive(:add_post_request)
    PersonRequest.send_to("http://google.com/")
  end

  it 'should allow me to see only friend requests sent to me' do 
    user = Factory.create(:user)
    remote_person = Factory.build(:user, :email => "robert@grimm.com", :url => "http://king.com/")

    PersonRequest.create(:destination_url => remote_person.url, :person => remote_person)
    PersonRequest.create(:destination_url => remote_person.url, :person => remote_person)
    PersonRequest.create(:destination_url => user.url, :person => user)

    PersonRequest.for_user(user).all.count.should == 1
  end

  it 'should allow me to see only friend requests sent by me' do 
    user = Factory.create(:user)
    remote_person = Factory.build(:user, :email => "robert@grimm.com", :url => "http://king.com/")

    PersonRequest.create(:destination_url => remote_person.url, :person => remote_person)
    PersonRequest.create(:destination_url => user.url, :person => user)
    PersonRequest.create(:destination_url => user.url, :person => user)

    PersonRequest.from_user(user).all.count.should == 1
  end

  describe "sending" do
    before do 
      @user = Factory.create(:user)
      @remote_person = Factory.build(:user, :email => "robert@grimm.com", :url => "http://king.com/")
    end


    it 'shoud be able to send a friend request' do 
      user = Factory.create(:user)
      remote_person = Factory.build(:user, :email => "robert@grimm.com", :url => "http://king.com/")





    end
  end
end
