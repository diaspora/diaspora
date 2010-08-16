require File.dirname(__FILE__) + '/../spec_helper'

describe Person do
  before do
    @user = Factory.create(:user)
    @user2 = Factory.create(:user)
    @person = Factory.create(:person)
    @group = @user.group(:name => "Dudes")
    @group2 = @user2.group(:name => "Abscence of Babes")
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
      
      request = @user.send_friend_request_to @person.receive_url, @group.id

      @user.activate_friend(@person, @group) 
      @user.reload
      
      Person.all.count.should == 3
      @user.friends.count.should == 1
      @user.unfriend(@person)
      @user.reload
      @user.friends.count.should == 0
      Person.all.count.should == 2
    end

    it 'should not delete an un-orphaned friend' do
      request = @user.send_friend_request_to @person.receive_url, @group.id
      request2 = @user2.send_friend_request_to @person.receive_url, @group2.id

      @user.activate_friend(@person, @group) 
      @user2.activate_friend(@person, @group2)

      @user.reload
      @user2.reload
      
      Person.all.count.should == 3
      @user.friends.count.should == 1
      @user2.friends.count.should == 1

      @user.unfriend(@person)
      @user.reload
      @user2.reload
      @user.friends.count.should == 0
      @user2.friends.count.should == 1

      Person.all.count.should == 3
    end
  end

end
