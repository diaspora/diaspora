require File.dirname(__FILE__) + '/../spec_helper'

describe Group do
  before do
    @user = Factory.create(:user)
    @friend = Factory.create(:person)
    @user2 = Factory.create(:user)
    @friend_2 = Factory.create(:person)
  end

  describe 'creation' do
    it 'should have a name' do
      group = @user.group(:name => 'losers')
      group.name.should == "losers"
    end

    it 'should be able to have people' do
      group = @user.group(:name => 'losers', :people => [@friend, @friend_2])
      group.people.size.should == 2
    end

    it 'should be able to have other users' do
      group = @user.group(:name => 'losers', :people => [@user2.person])
      group.people.include?(@user.person).should be false
      group.people.include?(@user2.person).should be true 
      group.people.size.should == 1
    end   

    it 'should be able to have users and people' do
      group = @user.group(:name => 'losers', :people => [@user2.person, @friend_2])
      group.people.include?(@user.person).should be false
      group.people.include?(@user2.person).should be true 
      group.people.include?(@friend_2).should be true 
      group.people.size.should == 2
    end
  end
  
  describe 'querying' do
    before do
      @group = @user.group(:name => 'losers', :people => [@friend])
    end

    it 'belong to a user' do
      @group.user.id.should == @user.id
      @user.groups.size.should == 1
      @user.groups.first.id.should == @group.id
    end

    it 'should have people' do
      @group.people.all.include?(@friend).should be true
      @group.people.size.should == 1
    end
  end

  describe 'posting' do
    
    it 'should add post to group via post method' do
      @group = @user.group(:name => 'losers', :people => [@friend])

      status_message = @user.post( :status_message, :message => "hey", :group => @group )
      
      @group.reload
      @group.my_posts.include?(status_message).should be true
    end

  end
end
