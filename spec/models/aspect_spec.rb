#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Aspect do
  let(:user ) { Factory.create(:user) }
  let(:friend) { Factory.create(:person) }
  let(:user2) { Factory.create(:user) }
  let(:friend_2) { Factory.create(:person) }

  let(:aspect) {user.aspect(:name => 'losers')}
  let(:aspect2) {user2.aspect(:name => 'failures')}
  let(:aspect1) {user.aspect(:name => 'cats')}
  let(:not_friend) { Factory(:person, :diaspora_handle => "not@person.com")}
  let(:user3) {Factory(:user)}
  let(:aspect3) {user3.aspect(:name => "lala")}

  describe 'creation' do
    it 'should have a name' do
      aspect = user.aspect(:name => 'losers')
      aspect.name.should == "losers"
    end

    it 'should be creatable with people' do
      aspect = user.aspect(:name => 'losers', :people => [friend, friend_2])
      aspect.people.size.should == 2
    end

    it 'should be able to have other users' do
      aspect = user.aspect(:name => 'losers', :people => [user2.person])
      aspect.people.include?(user.person).should be false
      aspect.people.include?(user2.person).should be true
      aspect.people.size.should == 1
    end

    it 'should be able to have users and people' do
      aspect = user.aspect(:name => 'losers', :people => [user2.person, friend_2])
      aspect.people.include?(user.person).should be false
      aspect.people.include?(user2.person).should be true
      aspect.people.include?(friend_2).should be true
      aspect.people.size.should == 2
    end
  end

  describe 'validation' do
    before do
      @aspect = user.aspect(:name => 'losers')
    end
    it 'has a unique name for one user' do
      aspect2 = user.aspect(:name => @aspect.name)
      aspect2.valid?.should be_false
    end

    it 'has no uniqueness between users' do
      aspect2 = user2.aspect(:name => @aspect.name)
      aspect2.valid?.should be_true
    end
  end

  describe 'querying' do
    before do
      @aspect = user.aspect(:name => 'losers')
      user.activate_friend(friend, @aspect)
      @aspect2 = user2.aspect(:name => 'failures')
      friend_users(user, @aspect, user2, @aspect2)
      @aspect.reload
    end

    it 'belong to a user' do
<<<<<<< HEAD
      @aspect.user.id.should == user.id
      user.aspects.size.should == 3
=======
      @aspect.user.id.should == @user.id
      @user.aspects.size.should == 1 
>>>>>>> 961510a8ed06590109a8090686355ffdcde71180
    end

    it 'should have people' do
      @aspect.people.all.include?(friend).should be true
      @aspect.people.size.should == 2
    end

    it 'should be accessible through the user' do
      aspects = user.aspects_with_person(friend)
      aspects.size.should == 1
      aspects.first.id.should == @aspect.id
      aspects.first.people.size.should == 2
      aspects.first.people.include?(friend).should be true
      aspects.first.people.include?(user2.person).should be true
    end
  end

  describe 'posting' do

    it 'should add post to aspect via post method' do
      aspect = user.aspect(:name => 'losers', :people => [friend])

      status_message = user.post( :status_message, :message => "hey", :to => aspect.id )

      aspect.reload
      aspect.posts.include?(status_message).should be true
    end

    it 'should add post to aspect via receive method' do
      aspect  = user.aspect(:name => 'losers')
      aspect2 = user2.aspect(:name => 'winners')
      friend_users(user, aspect, user2, aspect2)

      message = user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)

      user.receive message.to_diaspora_xml, user2.person

      aspect.reload
      aspect.posts.include?(message).should be true
      user.visible_posts(:by_members_of => aspect).include?(message).should be true
    end

    it 'should retract the post from the aspects as well' do
      aspect  = user.aspect(:name => 'losers')
      aspect2 = user2.aspect(:name => 'winners')
      friend_users(user, aspect, user2, aspect2)

      message = user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)

      user.receive message.to_diaspora_xml, user2.person
      aspect.reload

      aspect.post_ids.include?(message.id).should be true

      retraction = user2.retract(message)
      user.receive retraction.to_diaspora_xml, user2.person


      aspect.reload
      aspect.post_ids.include?(message.id).should be false
    end
  end

  context "aspect management" do


    before do
      friend_users(user, aspect, user2, aspect2)
      aspect.reload
      user.reload
    end
    

    describe "#add_person_to_aspect" do
      it 'adds the user to the aspect' do
        aspect1.people.should_not include user2.person
        user.add_person_to_aspect(user2.person.id, aspect1.id)
        aspect1.reload
        aspect1.people.should include user2.person
      end

      it 'raises if its an aspect that the user does not own'do
        proc{user.add_person_to_aspect(user2.person.id, aspect2.id) }.should raise_error /Can not add person to an aspect you do not own/
      end

      it 'does not allow to have duplicate people in an aspect' do
        proc{user.add_person_to_aspect(not_friend.id, aspect1.id) }.should raise_error /Can not add person you are not friends with/
      end

      it 'does not allow you to add a person if they are already in the aspect' do
        proc{user.add_person_to_aspect(user2.person.id, aspect.id) }.should raise_error /Can not add person who is already in the aspect/
      end
    end

    describe '#delete_person_from_aspect' do
      it 'deletes a user from the aspect' do
         user.add_person_to_aspect(user2.person.id, aspect1.id)
         user.reload
         user.aspects.find_by_id(aspect1.id).people.include?(user2.person).should be true
         user.delete_person_from_aspect(user2.person.id, aspect1.id)
         user.reload
         user.aspects.find_by_id(aspect1.id).people.include?(user2.person).should be false
      end

      it 'should check to make sure you have the aspect ' do
        proc{user.delete_person_from_aspect(user2.person.id, aspect2.id) }.should raise_error /Can not delete a person from an aspect you do not own/
      end
    end

    context 'moving and removing posts' do

      let(:message) { user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)}
      let(:message2){user3.post(:status_message, :message => "other post", :to => aspect3.id)}

      before do
        friend_users(user, aspect, user3, aspect3)
        user.receive message.to_diaspora_xml, user2.person
        user.receive message2.to_diaspora_xml, user3.person
        aspect.reload
        @post_count  = aspect.posts.count
        @post_count1 = aspect1.posts.count

        user.reload
      end
      
      it 'moves the persons posts into the new aspect' do
        user.add_person_to_aspect(user2.person.id, aspect1.id, :posts => [message] )
        aspect1.reload
        aspect1.posts.should == [message]
      end

      
      it 'should remove the users posts from that aspect' do
        user.delete_person_from_aspect(user2.person.id, aspect.id)
        aspect.reload
        aspect.posts.count.should == @post_count - 1
      end

      it 'should not delete other peoples posts' do
        user.delete_person_from_aspect(user2.person.id, aspect.id)
        aspect.reload
        aspect.posts.should == [message2]
      end

      describe '#move_friend' do
        it 'should be able to move a friend from one of users existing aspects to another' do
          user.move_friend(:friend_id => user2.person.id, :from => aspect.id, :to => aspect1.id)
          aspect.reload
          aspect1.reload

          aspect.person_ids.include?(user2.person.id).should be false
          aspect1.people.include?(user2.person).should be true
        end

        it "should not move a person who is not a friend" do
          proc{ user.move_friend(:friend_id => friend.id, :from => aspect.id, :to => aspect1.id) }.should raise_error /Can not add person you are not friends with/
          aspect.reload
          aspect1.reload
          aspect.people.include?(friend).should be false
          aspect1.people.include?(friend).should be false
        end

        it "should not move a person to a aspect that's not his" do
          proc {user.move_friend(:friend_id => user2.person.id, :from => aspect.id, :to => aspect2.id )}.should raise_error /Can not add person to an aspect you do not own/
          aspect.reload
          aspect2.reload
          aspect.people.include?(user2.person).should be true
          aspect2.people.include?(user2.person).should be false
        end

        it 'should move all posts by that user to the new aspect' do
          user.move_friend(:friend_id => user2.person.id, :from => aspect.id, :to => aspect1.id)
          aspect.reload
          aspect1.reload

          aspect1.posts.count.should == @post_count1 + 1
          aspect.posts.count.should == @post_count - 1
        end

        it 'does not try to delete if add person did not go through' do
          user.should_receive(:add_person_to_aspect).and_return(false)
          user.should_not_receive(:delete_person_from_aspect)
          user.move_friend(:friend_id => user2.person.id, :from => aspect.id, :to => aspect1.id)
        end
      end
    end
  end
end
