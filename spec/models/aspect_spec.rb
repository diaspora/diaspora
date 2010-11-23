#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Aspect do
  let(:user ) { make_user }
  let(:connected_person) { Factory.create(:person) }
  let(:user2) { make_user }
  let(:connected_person_2) { Factory.create(:person) }

  let(:aspect) {user.aspects.create(:name => 'losers')}
  let(:aspect2) {user2.aspects.create(:name => 'failures')}
  let(:aspect1) {user.aspects.create(:name => 'cats')}
  let(:not_contact) { Factory(:person, :diaspora_handle => "not@person.com")}
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
      aspect = user.aspects.create(:name => 'losers', :contacts => [connected_person, connected_person_2])
      aspect.contacts.size.should == 0
    end

    it 'should be able to have other users' do
      Contact.create(:user => user, :person => user2.person, :aspects => [aspect])
      aspect.contacts.first(:person_id => user.person.id).should be_nil
      aspect.contacts.first(:person_id => user2.person.id).should_not be_nil
      aspect.contacts.size.should == 1
    end

    it 'should be able to have users and people' do
      contact1 = Contact.create(:user => user, :person => user2.person, :aspects => [aspect])
      contact2 = Contact.create(:user => user, :person => connected_person_2, :aspects => [aspect])
      aspect.contacts.include?(contact1).should be_true
      aspect.contacts.include?(contact2).should be_true
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
      user.activate_contact(connected_person, aspect)
    end

    it 'belong to a user' do
      aspect.user.id.should == user.id
      user.aspects.should == [aspect]
    end

    it 'should have contacts' do
      aspect.contacts.size.should == 1
    end

    describe '#aspects_with_person' do
      let!(:aspect_without_contact) {user.aspects.create(:name => "Another aspect")}
      it 'should return the aspects with given contact' do
        user.reload
        aspects = user.aspects_with_person(connected_person)
        aspects.size.should == 1
        aspects.first.should == aspect
      end

      it 'returns multiple aspects if the person is there' do
        user.reload
        user.add_person_to_aspect(connected_person.id, aspect1.id)
        aspects = user.aspects_with_person(connected_person)
        aspects.count.should == 2
        contact = user.contact_for(connected_person)
        aspects.each{ |asp| asp.contacts.include?(contact).should be_true }
        aspects.include?(aspect_without_contact).should be_false
      end
    end
  end

  describe 'posting' do

    it 'should add post to aspect via post method' do
      aspect = user.aspects.create(:name => 'losers', :contacts => [connected_person])

      status_message = user.post( :status_message, :message => "hey", :to => aspect.id )

      aspect.reload
      aspect.posts.include?(status_message).should be true
    end

    it 'should add post to aspect via receive method' do
      aspect  = user.aspects.create(:name => 'losers')
      aspect2 = user2.aspects.create(:name => 'winners')
      connect_users(user, aspect, user2, aspect2)

      message = user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)

      aspect.reload
      aspect.posts.include?(message).should be true
      user.visible_posts(:by_members_of => aspect).include?(message).should be true
    end

    it 'should retract the post from the aspects as well' do
      aspect  = user.aspects.create(:name => 'losers')
      aspect2 = user2.aspects.create(:name => 'winners')
      connect_users(user, aspect, user2, aspect2)

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
      connect_users(user, aspect, user2, aspect2)
      aspect.reload
      user.reload
    end
    

    describe "#add_person_to_aspect" do
      it 'adds the user to the aspect' do
        aspect1.contacts.include?(contact).should be_false 
        user.add_person_to_aspect(user2.person.id, aspect1.id)
        aspect1.reload
        aspect1.contacts.include?(contact).should be_true
      end

      it 'raises if its an aspect that the user does not own'do
        proc{user.add_person_to_aspect(user2.person.id, aspect2.id) }.should raise_error /Can not add person to an aspect you do not own/
      end

      it 'does not allow to have duplicate contacts in an aspect' do
        proc{user.add_person_to_aspect(not_contact.id, aspect1.id) }.should raise_error /Can not add person you are not connected to/
      end

      it 'does not allow you to add a person if they are already in the aspect' do
        proc{user.add_person_to_aspect(user2.person.id, aspect.id) }.should raise_error /Can not add person who is already in the aspect/
      end
    end

    describe '#delete_person_from_aspect' do
      it 'deletes a user from the aspect' do
        user.add_person_to_aspect(user2.person.id, aspect1.id)
        user.reload
        user.delete_person_from_aspect(user2.person.id, aspect1.id)
        user.reload
        aspect1.reload.contacts.include?(contact).should be false
      end

      it 'should check to make sure you have the aspect ' do
        proc{user.delete_person_from_aspect(user2.person.id, aspect2.id) }.should raise_error /Can not delete a person from an aspect you do not own/
      end

      it 'deletes no posts' do
         user.add_person_to_aspect(user2.person.id, aspect1.id)
         user.reload
         user2.post(:status_message, :message => "Hey Dude", :to => aspect2.id)
         lambda{
           user.delete_person_from_aspect(user2.person.id, aspect1.id)
         }.should_not change(Post, :count)
      end

      it 'should not allow removing a contact from their last aspect' do
        proc{user.delete_person_from_aspect(user2.person.id, aspect.id) }.should raise_error /Can not delete a person from last aspect/
      end

      it 'should allow a force removal of a contact from an aspect' do
        contact.aspect_ids.should_receive(:count).exactly(0).times

        user.add_person_to_aspect(user2.person.id, aspect1.id)
        user.delete_person_from_aspect(user2.person.id, aspect.id, :force => true)
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
      
      it 'should keep the contact\'s posts in previous aspect' do
        aspect.post_ids.count.should == 1
        user.delete_person_from_aspect(user2.person.id, aspect.id, :force => true)

        aspect.reload
        aspect.post_ids.count.should == 1
      end

      it 'should not delete other peoples posts' do
        connect_users(user, aspect, user3, aspect3)
        user.delete_person_from_aspect(user3.person.id, aspect.id, :force => true)
        aspect.reload
        aspect.posts.should == [@message]
      end

      describe '#move_contact' do
        it 'should be able to move a contact from one of users existing aspects to another' do
          user.move_contact(:person_id => user2.person.id, :from => aspect.id, :to => aspect1.id)
          aspect.reload
          aspect1.reload

          aspect.contacts.include?(contact).should be_false
          aspect1.contacts.include?(contact).should be_true
        end

        it "should not move a person who is not a contact" do
          proc{ user.move_contact(:person_id => connected_person.id, :from => aspect.id, :to => aspect1.id) }.should raise_error /Can not add person you are not connected to/
          aspect.reload
          aspect1.reload
          aspect.contacts.first(:person_id => connected_person.id).should be_nil
          aspect1.contacts.first(:person_id => connected_person.id).should be_nil
        end

        it "should not move a person to a aspect that's not his" do
          proc {user.move_contact(:person_id => user2.person.id, :from => aspect.id, :to => aspect2.id )}.should raise_error /Can not add person to an aspect you do not own/
          aspect.reload
          aspect2.reload
          aspect.contacts.include?(contact).should be true
          aspect2.contacts.include?(contact).should be false
        end

        it 'does not try to delete if add person did not go through' do
          user.should_receive(:add_person_to_aspect).and_return(false)
          user.should_not_receive(:delete_person_from_aspect)
          user.move_contact(:person_id => user2.person.id, :from => aspect.id, :to => aspect1.id)
        end
      end
    end
  end
end
