#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let!(:user2) { Factory(:user_with_aspect) }

  context 'with two posts' do
    let!(:status_message1) { user2.post :status_message, :message => "hi", :to => user2.aspects.first.id }
    let!(:status_message2) { user2.post :status_message, :message => "hey", :public => true , :to => user2.aspects.first.id }
    

  
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
        let!(:user)          {make_user}
        let!(:first_aspect)  {user.aspect(:name => 'bruisers')}
        let!(:second_aspect) {user.aspect(:name => 'losers')}

        it "queries by aspect" do
          friend_users(user, first_aspect, user2, user2.aspects.first)
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
  end

  context 'with two users' do
    let!(:user)          {make_user}
    let!(:first_aspect)  {user.aspect(:name => 'bruisers')}
    let!(:second_aspect) {user.aspect(:name => 'losers')}
    let!(:user4) { Factory.create(:user_with_aspect)}

    before do
        friend_users(user, first_aspect, user4, user4.aspects.first)
        friend_users(user, second_aspect, user2, user2.aspects.first)
    end

    describe '#friends_not_in_aspect' do
      it 'finds the people who are not in the given aspect' do
        people = user.friends_not_in_aspect(first_aspect)
        people.should == [user2.person]
      end
    end

    describe '#person_objects' do
      it 'returns "person" objects for all of my friends' do
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
      it 'should return people objects for a users friend in each aspect' do
        people = user.people_in_aspects([first_aspect])
        people.should == [user4.person]
        people = user.people_in_aspects([second_aspect])
        people.should == [user2.person]
      end
    end
  end



  describe '#albums_by_aspect' do
    let!(:first_aspect)  {user2.aspect(:name => 'bruisers')}
    let!(:second_aspect) {user2.aspect(:name => 'losers')}
    before do
      user2.post :album, :name => "Georges", :to => first_aspect.id
      user2.post :album, :name => "Borges", :to => first_aspect.id
      user2.post :album, :name => "Luises", :to => second_aspect.id
      user2.reload
    end

    it 'should find all albums if passed :all' do
      user2.albums_by_aspect(:all).should have(3).albums
    end

    it 'should return the right number of albums' do
      user2.albums_by_aspect(first_aspect.reload).should have(2).albums
      user2.albums_by_aspect(second_aspect.reload).should have(1).album
    end
  end
end
