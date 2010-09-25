#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let(:user)  { Factory(:user) }
  let(:user2) { Factory(:user) }
  let(:user3) { Factory(:user) }
  let(:user4) { Factory(:user) }

  let(:aspect)   {user.aspect(:name => 'heroes')}
  let!(:aspect1) {user.aspect(:name => 'heroes')}
  let!(:aspect2) {user2.aspect(:name => 'losers')}
  let!(:aspect3) {user3.aspect(:name => 'heroes')}
  let!(:aspect4) {user4.aspect(:name => 'heroes')}

  before do
    friend_users(user, aspect, user2, aspect2)
    friend_users(user, aspect, user3, aspect3)
    friend_users(user, aspect1, user4, aspect4)
  end

  context 'posting' do

    describe '#validate_aspect_permissions' do
      it 'should not be able to post without a aspect' do
        proc {
          user.validate_aspect_permissions([])
        }.should raise_error /You must post to someone/
      end

      it 'should not be able to post to someone elses aspect' do
        proc {
          user.validate_aspect_permissions(aspect2.id)
        }.should raise_error /Cannot post to an aspect you do not own./
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
    end

    describe '#repost' do
      let!(:status_message) { user.post(:status_message, :message => "hello", :to => aspect.id) }

      it 'should make the post visible in another aspect' do
        user.repost( status_message, :to => aspect1.id )
        aspect1.reload
        aspect1.posts.count.should be 1
      end
    end

    describe '#update_post' do
      let!(:album) { user.post(:album, :name => "Profile Photos", :to => aspect.id) }

      it 'should update fields' do
        update_hash = { :name => "Other Photos" }
        user.update_post( album, update_hash )
        album.name.should == "Other Photos"
      end
    end
  end

  context 'dispatching' do
    let!(:post) { user.build_post :status_message, :message => "hey" }

    describe '#push_to_aspects' do
      it 'should push a post to a aspect' do
        user.should_receive(:salmon).twice
        user.push_to_aspects(post, aspect.id)
      end

      it 'should push a post to all aspects' do
        user.should_receive(:salmon).exactly(3).times
        user.push_to_aspects(post, :all)
      end
    end

    describe '#push_to_people' do
      it 'should push to people' do
        user.should_receive(:salmon).twice
        user.push_to_people(post, [user2.person, user3.person])
      end
    end
  end
end
