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
      @group = @user.group(:name => 'losers')
      @user.activate_friend(@friend, @group)
      @group2 = @user2.group(:name => 'failures')
      friend_users(@user, @group, @user2, @group2)
      @group.reload
    end

    it 'belong to a user' do
      @group.user.id.should == @user.id
      @user.groups.size.should == 1
      @user.groups.first.id.should == @group.id
    end

    it 'should have people' do
      @group.people.all.include?(@friend).should be true
      @group.people.size.should == 2
    end

    it 'should be accessible through the user' do
      groups = @user.groups_with_person(@friend)
      groups.size.should == 1
      groups.first.id.should == @group.id
      groups.first.people.size.should == 2
      groups.first.people.include?(@friend).should be true
      groups.first.people.include?(@user2.person).should be true
    end
  end

  describe 'posting' do
    
    it 'should add post to group via post method' do
      group = @user.group(:name => 'losers', :people => [@friend])

      status_message = @user.post( :status_message, :message => "hey", :group_ids => [group.id] )
      
      group.reload
      group.posts.include?(status_message).should be true
    end

    it 'should add post to group via receive method' do
      group  = @user.group(:name => 'losers')
      group2 = @user2.group(:name => 'winners')
      friend_users(@user, group, @user2, group2)

      message = @user2.post(:status_message, :message => "Hey Dude")
      
      @user.receive message.to_diaspora_xml
      
      group.reload
      group.posts.include?(message).should be true
      @user.visible_posts(:by_members_of => group).include?(message).should be true
    end

    it 'should retract the post from the groups as well' do 
      group  = @user.group(:name => 'losers')
      group2 = @user2.group(:name => 'winners')
      friend_users(@user, group, @user2, group2)

      message = @user2.post(:status_message, :message => "Hey Dude")
      
      @user.receive message.to_diaspora_xml
      group.reload
  
      group.post_ids.include?(message.id).should be true

      retraction = @user2.retract(message)
      @user.receive retraction.to_diaspora_xml

      group.reload
      group.post_ids.include?(message.id).should be false
    end
  end

end
