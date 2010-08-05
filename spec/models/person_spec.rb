require File.dirname(__FILE__) + '/../spec_helper'

describe Person do
  it 'should not allow two people with the same email' do
    person_one = Factory.create(:person)
    person_two = Factory.build(:person, :url => person_one.email)
    person_two.valid?.should == false
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

  describe "unfriending" do
    it 'should delete an orphaned friend' do
      user = Factory.create(:user)
      user.save
      
      person = Factory.create(:person)

      user.friends << person
      person.user_refs += 1
      person.save

      Person.all.count.should == 2
      user.friends.count.should == 1
      user.unfriend(person.id)
      user.friends.count.should == 0
      Person.all.count.should == 1
    end

    it 'should not delete an un-orphaned friend' do
      user_one = Factory.create(:user)
      user_two = Factory.create(:user)

      user_one.save
      user_two.save

      person = Factory.create(:person)

      user_one.friends << person
      user_two.friends << person
      user_one.save
      user_two.save

      person.user_refs += 2
      person.save

      Person.all.count.should == 3
      user_one.friends.count.should == 1
      user_two.friends.count.should == 1

      user_one.unfriend(person.id)

      user_one.friends.count.should == 0
      user_two.friends.count.should == 1

      Person.all.count.should == 3
    end
  end

end
