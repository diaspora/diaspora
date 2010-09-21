#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require File.dirname(__FILE__) + '/../../spec_helper'

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
    describe '#post' do
      it 'should not be able to post without a aspect' do
        proc {user.post(:status_message, :message => "heyheyhey")}.should raise_error /You must post to someone/
      end

      it 'should not be able to post to someone elses aspect' do
        proc {user.post(:status_message, :message => "heyheyhey", :to => aspect2.id)}.should raise_error /Cannot post to an aspect you do not own./
      end
      
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
