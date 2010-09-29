#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let!(:user) { Factory(:user_with_aspect) }
  let!(:first_aspect) { user.aspects.first }
  let!(:second_aspect) { user.aspect(:name => 'losers') }

  let!(:user2) { Factory(:user_with_aspect) }

  let!(:status_message1) { user2.post :status_message, :message => "hi", :to => user2.aspects.first.id }
  let!(:status_message2) { user2.post :status_message, :message => "hey", :public => true , :to => user2.aspects.first.id }
  let!(:status_message3) { user2.post :status_message, :message => "va", :to => user2.aspects.first.id }
  let!(:status_message4) { user2.post :status_message, :message => "da", :public => true , :to => user2.aspects.first.id }


  before do
    friend_users(user, first_aspect, user2, user2.aspects.first)
  end

  describe "#visible_posts" do
    it "queries by person id" do
      user2.visible_posts(:person_id => user2.person.id).include?(status_message1).should == true
      user2.visible_posts(:person_id => user2.person.id).include?(status_message2).should == true
      user2.visible_posts(:person_id => user2.person.id).include?(status_message3).should == true
      user2.visible_posts(:person_id => user2.person.id).include?(status_message4).should == true
    end

    it "selects public posts" do
      user2.visible_posts(:public => true).include?(status_message2).should == true
      user2.visible_posts(:public => true).include?(status_message4).should == true
    end

    it "selects non public posts" do
      user2.visible_posts(:public => false).include?(status_message1).should == true
      user2.visible_posts(:public => false).include?(status_message3).should == true
    end

    it "selects by message contents" do
      user2.visible_posts(:message => "hi").include?(status_message1).should == true
    end

    it "queries by aspect" do
      user3 = Factory(:user_with_aspect)
      status_message2 = user3.post :status_message, :message => "heyyyy", :to => user3.aspects.first.id
      user4 = Factory(:user_with_aspect)
      status_message3 = user4.post :status_message, :message => "yooo", :to => user4.aspects.first.id

      friend_users(user, second_aspect, user3, user3.aspects.first)
      friend_users(user, second_aspect, user4, user4.aspects.first)

      user.receive status_message1.to_diaspora_xml
      user.receive status_message2.to_diaspora_xml
      user.receive status_message3.to_diaspora_xml

      user.visible_posts(:by_members_of => first_aspect).should =~ [status_message1]
      user.visible_posts(:by_members_of => second_aspect).should =~ [status_message2, status_message3]
    end
  end

  context 'querying' do
    describe '#find_visible_post_by_id' do
      it 'should query' do
        user2.find_visible_post_by_id(status_message1.id).should == status_message1
        user.find_visible_post_by_id(status_message1.id).should == nil
      end
    end
  end

  context 'albums' do

    before do
      user.post :album, :name => "Georges", :to => first_aspect.id
      user.post :album, :name => "Borges", :to => first_aspect.id
      user.post :album, :name => "Luises", :to => second_aspect.id
      user.reload
    end

    it 'should find all albums if passed :all' do
      user.albums_by_aspect(:all).should have(3).albums
    end

    it 'should return the right number of albums' do
      user.albums_by_aspect(first_aspect.reload).should have(2).albums
      user.albums_by_aspect(second_aspect.reload).should have(1).album
    end
  end
end

