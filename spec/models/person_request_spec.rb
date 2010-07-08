require 'spec_helper'

describe PersonRequest do 

  it 'should require a url' do
    person_request = PersonRequest.new
    person_request.valid?.should be false
    person_request.url = "http://google.com/"
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
    PersonRequest.for("http://www.google.com")
  end

  it "should activate a person if it exists on creation of a request for that url" do
    user = Factory.create(:user)
    person = Factory.create(:person, :url => "http://123google.com/")
    PersonRequest.for(person.url)
    Person.where(:url => person.url).first.active.should be true
  end

end
