#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let!(:user) { alice }
  let!(:user2) { eve }

  let!(:aspect) { user.aspects.first }
  let!(:aspect1) { user.aspects.create(:name => 'other') }
  let!(:aspect2) { user2.aspects.first }

  let!(:service1) { Factory(:service, :type => 'Services::Twitter' , :user => user) }
  let!(:service2) { Factory(:service, :type => 'Services::Facebook', :user => user) }

  describe '#add_to_streams' do
    before do
      @params = {:message => "hey", :to => [aspect.id, aspect1.id]}
      @post = user.build_post(:status_message, @params)
      @post.save
      @aspect_ids = @params[:to]
      @aspects = user.aspects_from_ids(@aspect_ids)
    end

    it 'saves post into visible post ids' do
      proc {
        user.add_to_streams(@post, @aspects)
      }.should change{user.raw_visible_posts.all.length}.by(1)
      user.reload.raw_visible_posts.should include @post
    end

    it 'saves post into each aspect in aspect_ids' do
      user.add_to_streams(@post, @aspects)
      aspect.reload.post_ids.should include @post.id
      aspect1.reload.post_ids.should include @post.id
    end

    it 'sockets the post to the poster' do
      @post.should_receive(:socket_to_user).with(user, anything)
      user.add_to_streams(@post, @aspects)
    end
  end

  describe '#aspects_from_ids' do
    it 'returns a list of all valid aspects a user can post to' do
      aspect_ids = Aspect.all.map(&:id)
      user.aspects_from_ids(aspect_ids).map{|a| a}.should ==
        user.aspects.map{|a| a} #Rspec matchers ftw
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
    it 'sets status_message#message' do
      post = user.build_post(:status_message, :message => "hey", :to => aspect.id)
      post.message.should == "hey"
    end
    it 'does not save a status_message' do
      post = user.build_post(:status_message, :message => "hey", :to => aspect.id)
      post.persisted?.should be_false
    end

    it 'does not save a photo' do
      post = user.build_post(:photo, :user_file => uploaded_photo, :to => aspect.id)
      post.persisted?.should be_false
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
end
