require File.dirname(__FILE__) + '/../spec_helper'

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

  it 'should only return active friends' do
    Factory.create(:person)
    Factory.create(:person, :active => false)
    Factory.create(:person, :active => false)

    Person.friends.all.count.should == 1
  end


  it 'should delete all of user except comments upon user deletion' do
    Factory.create(:user)

    f = Factory.create(:person)
    p = Factory.create(:person)
    Factory.create(:status_message, :person => f)
    Factory.create(:blog, :person => f)
    Factory.create(:bookmark, :person => f)
    Factory.create(:status_message, :person => f)
    s = Factory.create(:status_message, :person => p)
   
    Factory.create(:comment, :person_id => f.id, :text => "yes i do", :post => s)
    Factory.create(:comment, :person_id => f.id, :text => "i love you", :post => s)
    Factory.create(:comment, :person_id => f.id, :text => "hello", :post => s)
    Factory.create(:comment, :person_id => p.id, :text => "you are creepy", :post => s)

    f.destroy

    Post.count.should == 1
    Comment.all.count.should == 4
    s.comments.count.should == 4
  end

  it 'should let a user unfriend another user' do
    u = Factory.create(:user)

    f = Factory.create(:person, :active => true)

    Person.friends.all.count.should == 1
    u.unfriend(f.id)
    Person.friends.all.count.should == 0
    Person.all.count.should == 1
  end

end
