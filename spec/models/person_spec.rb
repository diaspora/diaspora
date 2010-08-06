require File.dirname(__FILE__) + '/../spec_helper'

describe Person do
  before do
    @person = Factory.create(:person)
  end
  it 'should not allow two people with the same email' do
    person_two = Factory.build(:person, :url => @person.email)
    person_two.valid?.should == false
  end

  describe 'xml' do
    before do 
      @xml = @person.to_xml.to_s
    end
    it 'should serialize to xml' do
      (@xml.include? "person").should == true
    end

    it 'should have a profile in its xml' do
      (@xml.include? "first_name").should == true
    end
  end
  
  it 'should know when a post belongs to it' do
    person_message = Factory.create(:status_message, :person => @person)
    person_two = Factory.create(:person)

    @person.owns?(person_message).should be true
    person_two.owns?(person_message).should be false
  end

  it 'should delete all of user except comments upon user deletion' do
    Factory.create(:user)

    f = Factory.create(:person)

    Factory.create(:status_message, :person => f)
    Factory.create(:blog, :person => f)
    Factory.create(:bookmark, :person => f)
    Factory.create(:status_message, :person => f)
    s = Factory.create(:status_message, :person => @person)
   
    Factory.create(:comment, :person_id => f.id, :text => "yes i do", :post => s)
    Factory.create(:comment, :person_id => f.id, :text => "i love you", :post => s)
    Factory.create(:comment, :person_id => f.id, :text => "hello", :post => s)
    Factory.create(:comment, :person_id => @person.id, :text => "you are creepy", :post => s)

    f.destroy

    Post.count.should == 1
    Comment.all.count.should == 4
    s.comments.count.should == 4
  end

  describe "unfriending" do
    it 'should delete an orphaned friend' do
      user = Factory.create(:user)
      user.save
      

      user.friends << @person
      @person.user_refs += 1
      @person.save

      Person.all.count.should == 2
      user.friends.count.should == 1
      user.unfriend(@person.id)
      user.friends.count.should == 0
      Person.all.count.should == 1
    end

    it 'should not delete an un-orphaned friend' do
      user_one = Factory.create(:user)
      user_two = Factory.create(:user)

      user_one.save
      user_two.save


      user_one.friends << @person
      user_two.friends << @person
      user_one.save
      user_two.save

      @person.user_refs += 2
      @person.save

      Person.all.count.should == 3
      user_one.friends.count.should == 1
      user_two.friends.count.should == 1

      user_one.unfriend(@person.id)

      user_one.friends.count.should == 0
      user_two.friends.count.should == 1

      Person.all.count.should == 3
    end
  end

end
