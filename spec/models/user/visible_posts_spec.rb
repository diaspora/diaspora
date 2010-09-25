#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require 'spec_helper'

describe User do
  let(:user) { Factory(:user) }

  let(:user2) { Factory(:user) }
  let(:user3) { Factory(:user) }
  let(:user4) { Factory(:user) }

  let!(:aspect)  { user.aspect(:name => 'heroes') }
  let!(:aspect2) { user.aspect(:name => 'losers') }

  let!(:user2_aspect) { user2.aspect(:name => 'dudes') }
  let!(:user3_aspect) { user3.aspect(:name => 'dudes') }
  let!(:user4_aspect) { user4.aspect(:name => 'dudes') }

  let(:status_message1) { user2.post :status_message, :message => "hi", :to => user2_aspect.id }
  let(:status_message2) { user3.post :status_message, :message => "heyyyy", :to => user3_aspect.id }
  let(:status_message3) { user4.post :status_message, :message => "yooo", :to => user4_aspect.id }

  before do
    friend_users(user, aspect, user2, user2_aspect)
    friend_users(user, aspect2, user3, user3_aspect)
    friend_users(user, aspect2, user4, user4_aspect)
  end

  it 'should generate a valid stream for a aspect of people' do
    (1..3).each{ |n|
      eval("user.receive status_message#{n}.to_diaspora_xml")
    }

    user.visible_posts(:by_members_of => aspect).should include status_message1
    user.visible_posts(:by_members_of => aspect).should_not include status_message2
    user.visible_posts(:by_members_of => aspect).should_not include status_message3

    user.visible_posts(:by_members_of => aspect2).should_not include status_message1
    user.visible_posts(:by_members_of => aspect2).should include status_message2
    user.visible_posts(:by_members_of => aspect2).should include status_message3
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
      @album = user.post :album, :name => "Georges", :to => aspect.id
      aspect.reload
      aspect2.reload
      user.reload

      @album2 = user.post :album, :name => "Borges", :to => aspect.id
      aspect.reload
      aspect2.reload
      user.reload

      user.post :album, :name => "Luises", :to => aspect2.id
      aspect.reload
      aspect2.reload
      user.reload
    end

    it 'should find all albums if passed :all' do
      user.albums_by_aspect(:all).should have(3).albums
    end

    it 'should return the right number of albums' do
      user.albums_by_aspect(aspect).should have(2).albums
      user.albums_by_aspect(aspect2).should have(1).album
    end
  end
end

