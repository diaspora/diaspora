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
      @xml.include?("person").should == true
    end

    it 'should have a profile in its xml' do
      @xml.include?("first_name").should == true
    end
  end
  
  it 'should know when a post belongs to it' do
    person_message = Factory.create(:status_message, :person => @person)
    person_two =     Factory.create(:person)

    @person.owns?(person_message).should be true
    person_two.owns?(person_message).should be false
  end

  it 'should delete all of user except comments upon user deletion' do
    person = Factory.create(:person)

    Factory.create(:status_message, :person => person)
    Factory.create(:status_message, :person => person)
    Factory.create(:status_message, :person => person)
    Factory.create(:status_message, :person => person)

    status_message = Factory.create(:status_message, :person => @person)
   
    Factory.create(:comment, :person_id => person.id,  :text => "yes i do",       :post => status_message)
    Factory.create(:comment, :person_id => person.id,  :text => "i love you",     :post => status_message)
    Factory.create(:comment, :person_id => person.id,  :text => "hello",          :post => status_message)
    Factory.create(:comment, :person_id => @person.id, :text => "you are creepy", :post => status_message)

    person.destroy

    Post.count.should == 1
    Comment.all.count.should == 4
    status_message.comments.count.should == 4
  end

  describe "unfriending" do
    it 'should delete an orphaned friend' do
      request = @user.send_friend_request_to @person.receive_url, @group.id

      @user.activate_friend(@person, @group) 
      @user.reload
      
      Person.all.count.should    == 3
      @user.friends.count.should == 1
      @user.unfriend(@person)
      @user.reload
      @user.friends.count.should == 0
      Person.all.count.should    == 2
    end

    it 'should not delete an un-orphaned friend' do
      request = @user.send_friend_request_to @person.receive_url, @group.id
      request2 = @user2.send_friend_request_to @person.receive_url, @group2.id

      @user.activate_friend(@person, @group) 
      @user2.activate_friend(@person, @group2)

      @user.reload
      @user2.reload
      
      Person.all.count.should     == 3
      @user.friends.count.should  == 1
      @user2.friends.count.should == 1

      @user.unfriend(@person)
      @user.reload
      @user2.reload
      @user.friends.count.should  == 0
      @user2.friends.count.should == 1

      Person.all.count.should     == 3
    end
  end

  describe 'searching' do
    before do
      @friend_one   = Factory.create(:person)
      @friend_two   = Factory.create(:person)
      @friend_three = Factory.create(:person)
      @friend_four  = Factory.create(:person)

      @friend_one.profile.first_name = "Robert"
      @friend_one.profile.last_name  = "Grimm"
      @friend_one.profile.save

      @friend_two.profile.first_name = "Eugene"
      @friend_two.profile.last_name  = "Weinstein"
      @friend_two.save

      @friend_three.profile.first_name = "Yevgeniy"
      @friend_three.profile.last_name  = "Dodis"
      @friend_three.save

      @friend_four.profile.first_name = "Casey"
      @friend_four.profile.last_name  = "Grippi"
      @friend_four.save
    end

    it 'should yield search results on partial names' do
      people = Person.search("Eu") 
      people.include?(@friend_two).should   == true
      people.include?(@friend_one).should   == false
      people.include?(@friend_three).should == false
      people.include?(@friend_four).should  == false

      people = Person.search("Wei") 
      people.include?(@friend_two).should   == true
      people.include?(@friend_one).should   == false
      people.include?(@friend_three).should == false
      people.include?(@friend_four).should  == false

      people = Person.search("Gri") 
      people.include?(@friend_one).should   == true
      people.include?(@friend_four).should  == true
      people.include?(@friend_two).should   == false
      people.include?(@friend_three).should == false
    end

    it 'should search by email exactly' do
      Person.by_webfinger(@friend_one.email).should == @friend_one
    end
    
    describe 'wall posting' do 
      it 'should be able to post on another persons wall' do
        
        #user2 is in user's group, user is in group2 on user
        friend_users(@user, @group, @user2, @group2)
        
        @user.person.post_to_wall(:person => @user2.person, :message => "youve got a great smile")
        @user.person.wall_posts.count.should == 1
        
      end
    end
    
  end
end
