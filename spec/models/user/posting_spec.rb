#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let!(:user) { make_user }
  let!(:user2) { make_user }

  let!(:aspect) { user.aspects.create(:name => 'heroes') }
  let!(:aspect1) { user.aspects.create(:name => 'other') }
  let!(:aspect2) { user2.aspects.create(:name => 'losers') }

  let!(:service1) { s = Factory(:service, :provider => 'twitter'); user.services << s; s }
  let!(:service2) { s = Factory(:service, :provider => 'facebook'); user.services << s; s }


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

  describe '#build_post' do
    it 'does not save a status_message' do
      post = user.build_post(:status_message, :message => "hey", :to => aspect.id)
      post.persisted?.should be_false
    end

    it 'does not save a photo' do
      post = user.build_post(:photo, :user_file => uploaded_photo, :to => aspect.id)
      post.persisted?.should be_false
    end

  end

  describe '#dispatch_post' do
    it 'should put the post in the aspect post array' do
      post = user.post(:status_message, :message => "hey", :to => aspect.id)
      aspect.reload
      aspect.posts.should include post
    end

    it "should add the post to that user's visible posts" do
      status_message = user.post :status_message, :message => "hi", :to => aspect.id
      user.reload
      user.raw_visible_posts.include?(status_message).should be true
    end

    it "posts to services if post is public" do
      message = "hello, world!"
      user.should_receive(:post_to_twitter).with(service1, message).exactly(1).times
      user.should_receive(:post_to_facebook).with(service2, message).exactly(1).times
      user.post :status_message, :message => message, :to => "all", :public => true
    end

    it "does not post to services if post is not public" do
      user.should_receive(:post_to_twitter).exactly(0).times
      user.should_receive(:post_to_facebook).exactly(0).times
      user.post :status_message, :message => "hi", :to => "all"
    end


    it 'should not socket a pending post' do 
      sm = user.build_post(:status_message, :message => "your mom", :to => aspect.id, :pending => true)      
      sm.should_not_receive(:socket_to_uid)
      user.dispatch_post(sm, :to => aspect.id) 
    end
  end

  describe '#post' do
    it 'should not create a post with invalid aspect' do
      pending "this would just causes db polution"
      post_count = Post.count
      proc { user.post(:status_message, :message => "hey", :to => aspect2.id) }.should raise_error /Cannot post to an aspect you do not own./
      Post.count.should == post_count
    end
  end

  describe '#update_post' do
    it 'should update fields' do
      photo = user.post(:photo, :user_file => uploaded_photo, :caption => "Old caption", :to => aspect.id)
      update_hash = {:caption => "New caption"}
      user.update_post(photo, update_hash)

      photo.caption.should match(/New/)
    end
  end

  context 'dispatching' do
    let!(:user3) { make_user }
    let!(:user4) { make_user }

    let!(:aspect3) { user3.aspects.create(:name => 'heroes') }
    let!(:aspect4) { user4.aspects.create(:name => 'heroes') }

    let!(:post) { user.build_post :status_message, :message => "hey" }

    before do
      connect_users(user, aspect, user2, aspect2)
      connect_users(user, aspect, user3, aspect3)
      connect_users(user, aspect1, user4, aspect4)
      user.add_person_to_aspect(user2.person.id, aspect1.id)
      user.reload
    end

    describe '#push_to_aspects' do
      it 'should push a post to a aspect' do
        user.should_receive(:push_to_person).twice
        user.push_to_aspects(post, aspect.id)
      end

      it 'should push a post to contacts in all aspects' do
        user.should_receive(:push_to_person).exactly(3).times
        user.push_to_aspects(post, :all)
      end
    end

    describe '#push_to_people' do
      it 'should push to people' do
        user.should_receive(:push_to_person).twice
        user.push_to_people(post, [user2.person, user3.person])
      end

      it 'does not use the queue for local transfer' do
        User::QUEUE.should_receive(:add_post_request).once

        remote_person = user4.person
        remote_person.owner_id = nil
        remote_person.save
        remote_person.reload

        user.push_to_people(post, [user2.person, user3.person, remote_person])
      end

    end

  end
end
