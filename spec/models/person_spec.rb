require 'spec_helper'

describe Person do
  it 'should not allow two people with the same url' do
    person_one = Factory.create(:person)
    person_two = Factory.build(:person, :url => person_one.url)
    person_two.valid?.should == false
  end
  
  it 'should not allow a person with the same url as the user' do
    user = Factory.create(:user)
    person = Factory.build(:person, :url => user.url)
    person.valid?.should == false
  end

  it 'should serialize to xml' do
    person = Factory.create(:person)
    xml = person.to_xml.to_s
    (xml.include? "person").should == true
  end

  it 'should have a profile in its xml' do
    person = Factory.create(:person)
    xml = person.to_xml.to_s
    (xml.include? "first_name").should == true
  end
end
