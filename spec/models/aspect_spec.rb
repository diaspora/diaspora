#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Aspect do
  let(:user ) { alice }
  let(:connected_person) { Factory.create(:person) }
  let(:user2) { eve }
  let(:connected_person_2) { Factory.create(:person) }

  let(:aspect) {user.aspects.first }
  let(:aspect2) {user2.aspects.first }
  let(:aspect1) {user.aspects.create(:name => 'cats')}
  let(:user3) {Factory.create(:user)}
  let(:aspect3) {user3.aspects.create(:name => "lala")}

  describe 'creation' do
    let!(:aspect){user.aspects.create(:name => 'losers')}
    it 'has a name' do
      aspect.name.should == "losers"
    end

    it 'does not allow duplicate names' do
      lambda {
        invalid_aspect = user.aspects.create(:name => "losers ")
      }.should_not change(Aspect, :count)
    end

    it 'validates case insensitiveness on names' do
      lambda {
        invalid_aspect = user.aspects.create(:name => "Losers ")
      }.should_not change(Aspect, :count)
    end

    it 'has a 20 character limit on names' do
      aspect = Aspect.new(:name => "this name is really too too too too too long")
      aspect.valid?.should == false
    end

    it 'is able to have other users as contacts' do
      Contact.create(:user => user, :person => user2.person, :aspects => [aspect])
      aspect.contacts.where(:person_id => user.person.id).should be_empty
      aspect.contacts.where(:person_id => user2.person.id).should_not be_empty
      aspect.contacts.size.should == 1
    end

    it 'is able to have users and people and contacts' do
      contact1 = Contact.create(:user => user, :person => user2.person, :aspects => [aspect])
      contact2 = Contact.create(:user => user, :person => connected_person_2, :aspects => [aspect])
      aspect.contacts.include?(contact1).should be_true
      aspect.contacts.include?(contact2).should be_true
      aspect.save.should be_true
    end

    it 'has a contacts_visible? method' do
      aspect.contacts_visible?.should be_true
    end
  end

  describe 'validation' do
    it 'has a unique name for one user' do
      aspect2 = user.aspects.create(:name => aspect.name)
      aspect2.valid?.should be_false
    end

    it 'has no uniqueness between users' do
      aspect = user.aspects.create(:name => "New Aspect")
      aspect2 = user2.aspects.create(:name => aspect.name)
      aspect2.should be_valid
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
      aspect.contacts.size.should == 2
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
        contact = user.contact_for(connected_person)
        user.add_contact_to_aspect(contact, aspect1)
        aspects = user.aspects_with_person(connected_person)
        aspects.count.should == 2
        aspects.each{ |asp| asp.contacts.include?(contact).should be_true }
        aspects.include?(aspect_without_contact).should be_false
      end
    end
  end

  describe 'posting' do

    it 'should add post to aspect via post method' do
      aspect = user.aspects.create(:name => 'losers')
      contact = aspect.contacts.create(:person => connected_person)

      status_message = user.post(:status_message, :text => "hey", :to => aspect.id)

      aspect.reload
      aspect.posts.include?(status_message).should be true
    end

    it 'should add post to aspect via receive method' do
      aspect  = user.aspects.create(:name => 'losers')
      aspect2 = user2.aspects.create(:name => 'winners')
      connect_users(user, aspect, user2, aspect2)

      message = user2.post(:status_message, :text => "Hey Dude", :to => aspect2.id)

      aspect.reload
      aspect.posts.include?(message).should be true
      user.visible_posts(:by_members_of => aspect).include?(message).should be true
    end

    it 'should retract the post from the aspects as well' do
      aspect  = user.aspects.create(:name => 'losers')
      aspect2 = user2.aspects.create(:name => 'winners')
      connect_users(user, aspect, user2, aspect2)

      message = user2.post(:status_message, :text => "Hey Dude", :to => aspect2.id)

      aspect.reload.post_ids.include?(message.id).should be true

      fantasy_resque do
        retraction = user2.retract(message)
      end
      aspect.posts(true).include?(message).should be false
    end
  end

  context "aspect management" do
    before do
      connect_users(user, aspect, user2, aspect2)
      aspect.reload
      user.reload
      @contact = user.contact_for(user2.person)
    end


    describe "#add_contact_to_aspect" do
      it 'adds the contact to the aspect' do
        aspect1.contacts.include?(@contact).should be_false
        user.add_contact_to_aspect(@contact, aspect1)
        aspect1.reload
        aspect1.contacts.include?(@contact).should be_true
      end

      it 'returns true if they are already in the aspect' do
        user.add_contact_to_aspect(@contact, aspect).should == true
      end
    end
    context 'moving and removing posts' do
      before do
        @message  = user2.post(:status_message, :text => "Hey Dude", :to => aspect2.id)
        aspect.reload
        user.reload
      end

      it 'should keep the contact\'s posts in previous aspect' do
        aspect.post_ids.count.should == 1
        user.move_contact(user2.person, user.aspects.create(:name => "Another aspect"), aspect)


        aspect.reload
        aspect.post_ids.count.should == 1
      end

      it 'should not delete other peoples posts' do
        connect_users(user, aspect, user3, aspect3)
        user.move_contact(user3.person, user.aspects.create(:name => "Another aspect"), aspect)
        aspect.reload
        aspect.posts.should == [@message]
      end

      describe '#move_contact' do
        it 'should be able to move a contact from one of users existing aspects to another' do
          user.move_contact(user2.person, aspect1, aspect)

          aspect.contacts(true).include?(@contact).should be_false
          aspect1.contacts(true).include?(@contact).should be_true
        end

        it "should not move a person who is not a contact" do
          proc{
            user.move_contact(connected_person, aspect1, aspect)
          }.should raise_error

          aspect.reload
          aspect1.reload
          aspect.contacts.where(:person_id => connected_person.id).should be_empty
          aspect1.contacts.where(:person_id => connected_person.id).should be_empty
        end

        it 'does not try to delete if add person did not go through' do
          user.should_receive(:add_contact_to_aspect).and_return(false)
          user.should_not_receive(:delete_person_from_aspect)
          user.move_contact(user2.person, aspect1, aspect)
        end
      end
    end
  end
end
