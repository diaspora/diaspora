#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let(:user)          {make_user}
  let!(:aspect) { user.aspects.create(:name => "cats")}
  let!(:user2) { Factory(:user_with_aspect) }
  let(:person_one) { Factory.create :person }
  let(:person_two) { Factory.create :person }
  let(:person_three) { Factory.create :person }


  context 'with two posts' do
    let!(:status_message1) { user2.post :status_message, :message => "hi", :to => user2.aspects.first.id }
    let!(:status_message2) { user2.post :status_message, :message => "hey", :public => true , :to => user2.aspects.first.id }
    let!(:status_message4) { user2.post :status_message, :message => "blah", :public => true , :to => user2.aspects.first.id }
    let!(:status_message3) { user.post :status_message, :message => "hey", :public => true , :to => user.aspects.first.id }


    describe "#visible_posts" do
      it "queries by person id" do
        query = user2.visible_posts(:person_id => user2.person.id)
        query.include?(status_message1).should == true
        query.include?(status_message2).should == true
      end

      it "selects public posts" do
        query = user2.visible_posts(:public => true)
        query.include?(status_message2).should == true
        query.include?(status_message1).should == false
      end

      it "selects non public posts" do
        query = user2.visible_posts(:public => false)
        query.include?(status_message1).should == true
        query.include?(status_message2).should == false
      end

      it "selects by message contents" do
        user2.visible_posts(:message => "hi").include?(status_message1).should == true
      end

      context 'with two users' do
        let!(:first_aspect)  {user.aspects.create(:name => 'bruisers')}
        let!(:second_aspect) {user.aspects.create(:name => 'losers')}

        it "queries by aspect" do
          connect_users(user, first_aspect, user2, user2.aspects.first)
          user.receive status_message1.to_diaspora_xml, user2.person

          user.visible_posts(:by_members_of => first_aspect).should =~ [status_message1]
          user.visible_posts(:by_members_of => second_aspect).should =~ []
        end
        it '#find_visible_post_by_id' do
          user2.find_visible_post_by_id(status_message1.id).should == status_message1
          user.find_visible_post_by_id(status_message1.id).should == nil
        end
      end
    end

    describe '#my_posts' do
      it 'should return only my posts' do
        posts2 = user2.my_posts
        posts2.should include status_message1
        posts2.should include status_message2
        posts2.should_not include status_message3
        user.my_posts.should include status_message3
      end

      it 'returns query objexts so chainable' do
        user2.my_posts.where(:_id => status_message1.id.to_s).all.should == [status_message1]

        pub_posts = user2.my_posts.where(:public => true).all

        pub_posts.should_not include status_message1
        pub_posts.should include status_message2
        pub_posts.should include status_message4
        pub_posts.should_not include status_message3

        user.my_posts.where(:public => false).all.should == []
      end
    end
  end

  context 'with two users' do
    let!(:user)          {make_user}
    let!(:first_aspect)  {user.aspects.create(:name => 'bruisers')}
    let!(:second_aspect) {user.aspects.create(:name => 'losers')}
    let!(:user4) { Factory.create(:user_with_aspect)}

    before do
      connect_users(user, first_aspect, user4, user4.aspects.first)
      connect_users(user, second_aspect, user2, user2.aspects.first)
    end

    describe '#contacts_not_in_aspect' do
      it 'finds the people who are not in the given aspect' do
        people = user.contacts_not_in_aspect(first_aspect)
        people.should == [user2.person]
      end
    end

    describe '#person_objects' do
      it 'returns "person" objects for all of my contacts' do
        people = user.person_objects
        people.size.should == 2
        [user4.person, user2.person].each{ |p| people.should include p }
      end

      it 'should return people objects given a collection of contacts' do
        target_contacts = [user.contact_for(user2.person)]
        people = user.person_objects(target_contacts) 
        people.should == [user2.person]
      end

    end

    describe '#people_in_aspects' do
      it 'should return people objects for a users contact in each aspect' do
        people = user.people_in_aspects([first_aspect])
        people.should == [user4.person]
        people = user.people_in_aspects([second_aspect])
        people.should == [user2.person]
      end
    end
  end

  context 'contact querying' do
    let(:person_one) { Factory.create :person }
    let(:person_two) { Factory.create :person }
    let(:person_three) { Factory.create :person }
    let(:aspect) { user.aspects.create(:name => 'heroes') }
    describe '#contact_for_person_id' do
      it 'returns a contact' do
        contact = Contact.create(:user => user, :person => person_one, :aspects => [aspect])
        user.contacts << contact
        user.contact_for_person_id(person_one.id).should be_true
      end

      it 'returns the correct contact' do
        contact = Contact.create(:user => user, :person => person_one, :aspects => [aspect])
        user.contacts << contact

        contact2 = Contact.create(:user => user, :person => person_two, :aspects => [aspect])
        user.contacts << contact2

        contact3 = Contact.create(:user => user, :person => person_three, :aspects => [aspect])
        user.contacts << contact3

        user.contact_for_person_id(person_two.id).person.should == person_two
      end

      it 'returns nil for a non-contact' do
        user.contact_for_person_id(person_one.id).should be_nil
      end

      it 'returns nil when someone else has contact with the target' do
        contact = Contact.create(:user => user, :person => person_one, :aspects => [aspect])
        user.contacts << contact
        user2.contact_for_person_id(person_one.id).should be_nil
      end
    end

    describe '#contact_for' do
      it 'takes a person_id and returns a contact' do
        user.should_receive(:contact_for_person_id).with(person_one.id)
        user.contact_for(person_one) 
      end
    end
  end

end
