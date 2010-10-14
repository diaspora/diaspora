#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Aspect do
  before do
    @user = Factory.create(:user)
    @friend = Factory.create(:person)
    @user2 = Factory.create(:user)
    @friend_2 = Factory.create(:person)
  end

  describe 'creation' do
    it 'should have a name' do
      aspect = @user.aspect(:name => 'losers')
      aspect.name.should == "losers"
    end

    it 'should be creatable with people' do
      aspect = @user.aspect(:name => 'losers', :people => [@friend, @friend_2])
      aspect.people.size.should == 2
    end

    it 'should be able to have other users' do
      aspect = @user.aspect(:name => 'losers', :people => [@user2.person])
      aspect.people.include?(@user.person).should be false
      aspect.people.include?(@user2.person).should be true
      aspect.people.size.should == 1
    end

    it 'should be able to have users and people' do
      aspect = @user.aspect(:name => 'losers', :people => [@user2.person, @friend_2])
      aspect.people.include?(@user.person).should be false
      aspect.people.include?(@user2.person).should be true
      aspect.people.include?(@friend_2).should be true
      aspect.people.size.should == 2
    end
  end

  describe 'querying' do
    before do
      @aspect = @user.aspect(:name => 'losers')
      @user.activate_friend(@friend, @aspect)
      @aspect2 = @user2.aspect(:name => 'failures')
      friend_users(@user, @aspect, @user2, @aspect2)
      @aspect.reload
    end

    it 'belong to a user' do
      @aspect.user.id.should == @user.id
      @user.aspects.size.should == 3
    end

    it 'should have people' do
      @aspect.people.all.include?(@friend).should be true
      @aspect.people.size.should == 2
    end

    it 'should be accessible through the user' do
      aspects = @user.aspects_with_person(@friend)
      aspects.size.should == 1
      aspects.first.id.should == @aspect.id
      aspects.first.people.size.should == 2
      aspects.first.people.include?(@friend).should be true
      aspects.first.people.include?(@user2.person).should be true
    end
  end

  describe 'posting' do

    it 'should add post to aspect via post method' do
      aspect = @user.aspect(:name => 'losers', :people => [@friend])

      status_message = @user.post( :status_message, :message => "hey", :to => aspect.id )

      aspect.reload
      aspect.posts.include?(status_message).should be true
    end

    it 'should add post to aspect via receive method' do
      aspect  = @user.aspect(:name => 'losers')
      aspect2 = @user2.aspect(:name => 'winners')
      friend_users(@user, aspect, @user2, aspect2)

      message = @user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)

      @user.receive message.to_diaspora_xml, @user2.person

      aspect.reload
      aspect.posts.include?(message).should be true
      @user.visible_posts(:by_members_of => aspect).include?(message).should be true
    end

    it 'should retract the post from the aspects as well' do
      aspect  = @user.aspect(:name => 'losers')
      aspect2 = @user2.aspect(:name => 'winners')
      friend_users(@user, aspect, @user2, aspect2)

      message = @user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)

      @user.receive message.to_diaspora_xml, @user2.person
      aspect.reload

      aspect.post_ids.include?(message.id).should be true

      retraction = @user2.retract(message)
      @user.receive retraction.to_diaspora_xml, @user2.person


      aspect.reload
      aspect.post_ids.include?(message.id).should be false
    end
  end

  describe "aspect editing" do
    before do
      @aspect = @user.aspect(:name => 'losers')
      @aspect2 = @user2.aspect(:name => 'failures')
      friend_users(@user, @aspect, @user2, @aspect2)
      @aspect.reload
      @aspect3 = @user.aspect(:name => 'cats')
      @user.reload
    end

    it 'should be able to move a friend from one of users existing aspects to another' do
      @user.move_friend(:friend_id => @user2.person.id, :from => @aspect.id, :to => @aspect3.id)
      @aspect.reload
      @aspect3.reload

      @aspect.person_ids.include?(@user2.person.id).should be false
      @aspect3.people.include?(@user2.person).should be true
    end

    it "should not move a person who is not a friend" do
      @user.move_friend(:friend_id => @friend.id, :from => @aspect.id, :to => @aspect3.id)
      @aspect.reload
      @aspect3.reload
      @aspect.people.include?(@friend).should be false
      @aspect3.people.include?(@friend).should be false
    end

    it "should not move a person to a aspect that's not his" do
      @user.move_friend(:friend_id => @user2.person.id, :from => @aspect.id, :to => @aspect2.id)
      @aspect.reload
      @aspect2.reload
      @aspect.people.include?(@user2.person).should be true
      @aspect2.people.include?(@user2.person).should be false
    end

    it 'should move all the by that user to the new aspect' do
      message = @user2.post(:status_message, :message => "Hey Dude", :to => @aspect2.id)

      @user.receive message.to_diaspora_xml, @user2.person
      @aspect.reload

      @aspect.posts.count.should == 1
      @aspect3.posts.count.should == 0

      @user.reload
      @user.move_friend(:friend_id => @user2.person.id, :from => @aspect.id, :to => @aspect3.id)
      @aspect.reload
      @aspect3.reload

      @aspect3.posts.count.should == 1
      @aspect.posts.count.should == 0

    end

  end
end
