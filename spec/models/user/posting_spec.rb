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

  describe '#add_to_streams' do
    before do
      @params = {:message => "hey", :to => [aspect.id, aspect1.id]}
      @post = user.build_post(:status_message, @params)
      @post.save
      @aspect_ids = @params[:to]
    end

    it 'saves post into visible post ids' do
      proc {
        user.add_to_streams(@post, @aspect_ids)
      }.should change(user.raw_visible_posts, :count).by(1)
      user.reload.raw_visible_posts.should include @post
    end

    it 'saves post into each aspect in aspect_ids' do
      user.add_to_streams(@post, @aspect_ids)
      aspect.reload.post_ids.should include @post.id
      aspect1.reload.post_ids.should include @post.id
    end

    it 'sockets the post to the poster' do 
      @post.should_receive(:socket_to_uid).with(user.id, anything)
      user.add_to_streams(@post, @aspect_ids)
    end
  end

  describe '#aspects_from_ids' do
    it 'returns a list of all valid aspects a user can post to' do
      aspect_ids = Aspect.all.map(&:id)
      user.aspects_from_ids(aspect_ids).should =~ [aspect, aspect1]
    end
    it "lets you post to your own aspects" do
      user.aspects_from_ids([aspect.id]).should == [aspect]
      user.aspects_from_ids([aspect1.id]).should == [aspect1]
    end
    it 'removes aspects that are not yours' do
      user.aspects_from_ids(aspect2.id).should == []
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
    include Rails.application.routes.url_helpers 
    let(:status) {user.build_post(:status_message, @status_opts)}
    before do
      @message = "hello, world!"
      @status_opts = {:to => "all", :message => @message}
    end
    it "posts to services if post is public" do
      @status_opts[:public] = true
      status.save
      user.should_receive(:post_to_twitter).with(service1, @message).once
      user.should_receive(:post_to_facebook).with(service2, @message).once
      user.dispatch_post(status, :to => "all")
    end

    it "does not post to services if post is not public" do
      @status_opts[:public] = false
      status.save
      user.should_not_receive(:post_to_twitter)
      user.should_not_receive(:post_to_facebook)
      user.dispatch_post(status, :to => "all")
    end

     it 'includes a permalink to my post' do
      @status_opts[:public] = true
      status.save
      user.should_receive(:post_to_twitter).with(service1, @message+ " #{post_path(status)}").once
      user.should_receive(:post_to_facebook).with(service2, @message + " #{post_path(status)}").once
      user.dispatch_post(status, :to => "all", :url => post_path(status))
    end

     it 'only pushes to services if it is a status message' do
        photo = Photo.new()
        photo.public = true
        user.stub!(:push_to_aspects)
        user.should_not_receive(:post_to_twitter)
        user.should_not_receive(:post_to_facebook)
        user.dispatch_post(photo, :to =>"all")
     end
  end
  
  describe '#post' do
    it 'should not create a post with invalid aspect' do
      pending "this would just cause db polution"
      proc {
        user.post(:status_message, :message => "hey", :to => aspect2.id) 
      }.should_not change(Post, :count)
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
        user.push_to_aspects(post, [aspect])
      end

      it 'should push a post to contacts in all aspects' do
        user.should_receive(:push_to_person).exactly(3).times
        user.push_to_aspects(post, user.aspects)
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
