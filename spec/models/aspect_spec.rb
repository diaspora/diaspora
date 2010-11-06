#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Aspect do
  let(:user ) { make_user }
  let(:friend) { Factory.create(:person) }
  let(:user2) { make_user }
  let(:friend_2) { Factory.create(:person) }

  let(:aspect) {user.aspects.create(:name => 'losers')}
  let(:aspect2) {user2.aspects.create(:name => 'failures')}
  let(:aspect1) {user.aspects.create(:name => 'cats')}
  let(:not_friend) { Factory(:person, :diaspora_handle => "not@person.com")}
  let(:user3) {make_user}
  let(:aspect3) {user3.aspects.create(:name => "lala")}

  describe 'creation' do
    let!(:aspect){user.aspects.create(:name => 'losers')}
    it 'should have a name' do
      aspect.name.should == "losers"
    end

    it 'should not allow duplicate names' do
      lambda {
        invalid_aspect = user.aspects.create(:name => "losers ")
      }.should_not change(Aspect, :count)
    end

    it 'should have a limit of 20 characters' do
      aspect = Aspect.new(:name => "this name is really too too too too too long")
      aspect.valid?.should == false
    end

    it 'should not be creatable with people' do
      aspect = user.aspects.create(:name => 'losers', :people => [friend, friend_2])
      aspect.people.size.should == 0
    end

    it 'should be able to have other users' do
      Contact.create(:user => user, :person => user2.person, :aspects => [aspect])
      aspect.people.first(:person_id => user.person.id).should be_nil
      aspect.people.first(:person_id => user2.person.id).should_not be_nil
      aspect.people.size.should == 1
    end

    it 'should be able to have users and people' do
      contact1 = Contact.create(:user => user, :person => user2.person, :aspects => [aspect])
      contact2 = Contact.create(:user => user, :person => friend_2, :aspects => [aspect])
      aspect.people.include?(contact1).should be_true
      aspect.people.include?(contact2).should be_true
      aspect.save.should be_true
    end
  end

  describe 'validation' do
    before do
      aspect
    end
    it 'has a unique name for one user' do
      aspect2 = user.aspects.create(:name => aspect.name)
      aspect2.valid?.should be_false
    end

    it 'has no uniqueness between users' do
      aspect2 = user2.aspects.create(:name => aspect.name)
      aspect2.valid?.should be_true
    end
  end

  describe 'querying' do
    before do
      aspect
      user.activate_friend(friend, aspect)
    end

    it 'belong to a user' do
      aspect.user.id.should == user.id
      user.aspects.should == [aspect]
    end

    it 'should have people' do
      aspect.people.first(:person_id => friend.id).should be_true
      aspect.people.size.should == 1
    end

    describe '#aspects_with_person' do
      let!(:aspect_without_friend) {user.aspects.create(:name => "Another aspect")}
      it 'should return the aspects with given friend' do
        user.reload
        aspects = user.aspects_with_person(friend)
        aspects.size.should == 1
        aspects.first.should == aspect
      end

      it 'returns multiple aspects if the person is there' do
        user.reload
        user.add_person_to_aspect(friend.id, aspect1.id)
        aspects = user.aspects_with_person(friend)
        aspects.count.should == 2
        contact = user.contact_for(friend)
        aspects.each{ |asp| asp.people.include?(contact).should be_true }
        aspects.include?(aspect_without_friend).should be_false
      end
    end
  end

  describe 'posting' do

    it 'should add post to aspect via post method' do
      aspect = user.aspects.create(:name => 'losers', :people => [friend])

      status_message = user.post( :status_message, :message => "hey", :to => aspect.id )

      aspect.reload
      aspect.posts.include?(status_message).should be true
    end

    it 'should add post to aspect via receive method' do
      aspect  = user.aspects.create(:name => 'losers')
      aspect2 = user2.aspects.create(:name => 'winners')
      friend_users(user, aspect, user2, aspect2)

      message = user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)

      aspect.reload
      aspect.posts.include?(message).should be true
      user.visible_posts(:by_members_of => aspect).include?(message).should be true
    end

    it 'should retract the post from the aspects as well' do
      aspect  = user.aspects.create(:name => 'losers')
      aspect2 = user2.aspects.create(:name => 'winners')
      friend_users(user, aspect, user2, aspect2)

      message = user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)

      aspect.reload.post_ids.include?(message.id).should be true

      retraction = user2.retract(message)

      aspect.reload
      aspect.post_ids.include?(message.id).should be false
    end
  end

  context "aspect management" do
    let(:contact){user.contact_for(user2.person)}
    before do
      friend_users(user, aspect, user2, aspect2)
      aspect.reload
      user.reload
    end
    

    describe "#add_person_to_aspect" do
      it 'adds the user to the aspect' do
        aspect1.people.include?(contact).should be_false 
        user.add_person_to_aspect(user2.person.id, aspect1.id)
        aspect1.reload
        aspect1.people.include?(contact).should be_true
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
         aspect1.reload.people.include?(contact).should be true
         user.delete_person_from_aspect(user2.person.id, aspect1.id)
         user.reload
         aspect1.reload.people.include?(contact).should be false
      end

      it 'should check to make sure you have the aspect ' do
        proc{user.delete_person_from_aspect(user2.person.id, aspect2.id) }.should raise_error /Can not delete a person from an aspect you do not own/
      end
    end

    context 'moving and removing posts' do


      before do
        @message  = user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)
        aspect.reload
        @post_count  = aspect.posts.count
        @post_count1 = aspect1.posts.count

        user.reload
      end
      
      it 'moves the persons posts into the new aspect' do
        user.add_person_to_aspect(user2.person.id, aspect1.id, :posts => [@message] )
        aspect1.reload
        aspect1.posts.should == [@message]
      end

      
      it 'should remove the users posts from that aspect' do
        user.delete_person_from_aspect(user2.person.id, aspect.id)
        aspect.reload
        aspect.posts.count.should == @post_count - 1
      end

      it 'should not delete other peoples posts' do
        friend_users(user, aspect, user3, aspect3)
        user.delete_person_from_aspect(user3.person.id, aspect.id)
        aspect.reload
        aspect.posts.should == [@message]
      end

      describe '#move_friend' do
        it 'should be able to move a friend from one of users existing aspects to another' do
          user.move_friend(:friend_id => user2.person.id, :from => aspect.id, :to => aspect1.id)
          aspect.reload
          aspect1.reload

          aspect.people.include?(contact).should be_false
          aspect1.people.include?(contact).should be_true
        end

        it "should not move a person who is not a friend" do
          proc{ user.move_friend(:friend_id => friend.id, :from => aspect.id, :to => aspect1.id) }.should raise_error /Can not add person you are not friends with/
          aspect.reload
          aspect1.reload
          aspect.people.first(:person_id => friend.id).should be_nil
          aspect1.people.first(:person_id => friend.id).should be_nil
        end

        it "should not move a person to a aspect that's not his" do
          proc {user.move_friend(:friend_id => user2.person.id, :from => aspect.id, :to => aspect2.id )}.should raise_error /Can not add person to an aspect you do not own/
          aspect.reload
          aspect2.reload
          aspect.people.include?(contact).should be true
          aspect2.people.include?(contact).should be false
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
