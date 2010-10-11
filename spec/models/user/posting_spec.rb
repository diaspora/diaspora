#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let!(:user) { Factory(:user) }
  let!(:aspect) { user.aspect(:name => 'heroes') }
  let!(:aspect1) { user.aspect(:name => 'other') }

  let!(:user2) { Factory(:user) }
  let!(:aspect2) { user2.aspect(:name => 'losers') }

  describe '#validate_aspect_permissions' do
    it 'requires an aspect' do
      proc {
        user.validate_aspect_permissions([])
      }.should raise_error /You must post to someone/
    end

    it "won't let you post to someone else's aspect" do
      proc {
        user.validate_aspect_permissions(aspect2.id)
      }.should raise_error /Cannot post to an aspect you do not own./
    end

    it "lets you post to your own aspects" do
      user.validate_aspect_permissions(aspect.id).should be_true
      user.validate_aspect_permissions(aspect1.id).should be_true
    end
  end

  describe '#post' do
    it 'should put the post in the aspect post array' do
      post = user.post(:status_message, :message => "hey", :to => aspect.id)
      aspect.reload
      aspect.posts.should include post
    end

    it 'should put an album in the aspect post array' do
      album = user.post :album, :name => "Georges", :to => aspect.id
      aspect.reload
      aspect.posts.should include album
    end
    it "should add the post to that user's visible posts" do
      status_message = user.post :status_message, :message => "hi", :to => aspect.id
      user.reload
      user.raw_visible_posts.include?(status_message).should be true
    end
  end

  describe '#update_post' do
    it 'should update fields' do
      album = user.post(:album, :name => "Profile Photos", :to => aspect.id)
      update_hash = {:name => "Other Photos"}
      user.update_post(album, update_hash)
      album.name.should == "Other Photos"
    end
  end

  context 'dispatching' do
    let!(:user3) { Factory(:user) }
    let!(:aspect3) { user3.aspect(:name => 'heroes') }
    let!(:user4) { Factory(:user) }
    let!(:aspect4) { user4.aspect(:name => 'heroes') }

    let!(:post) { user.build_post :status_message, :message => "hey" }

    before do
      friend_users(user, aspect, user2, aspect2)
      friend_users(user, aspect, user3, aspect3)
      friend_users(user, aspect1, user4, aspect4)
    end

    describe '#push_to_aspects' do
      it 'should push a post to a aspect' do
        user.should_receive(:push_to_person).twice
        user.push_to_aspects(post, aspect.id)
      end

      it 'should push a post to all aspects' do
        user.should_receive(:push_to_person).exactly(3).times
        user.push_to_aspects(post, :all)
      end
    end

    describe '#push_to_people' do
      it 'should push to people' do
        user.should_receive(:push_to_person).twice
        user.push_to_people(post, [user2.person, user3.person])
      end
    end
  end
end
