#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  before do
    @aspect = alice.aspects.first
    @aspect1 = alice.aspects.create(:name => 'other')
  end

  describe '#add_to_streams' do
    before do
      @params = {:text => "hey", :to => [@aspect.id, @aspect1.id]}
      @post = alice.build_post(:status_message, @params)
      @post.save
      @aspect_ids = @params[:to]
      @aspects = alice.aspects_from_ids(@aspect_ids)
    end

    it 'saves post into visible post ids' do
      lambda {
        alice.add_to_streams(@post, @aspects)
      }.should change{alice.visible_shareables(Post, :by_members_of => @aspects).length}.by(1)
      alice.visible_shareables(Post, :by_members_of => @aspects).should include @post
    end

    it 'saves post into each aspect in aspect_ids' do
      alice.add_to_streams(@post, @aspects)
      @aspect.reload.post_ids.should include @post.id
      @aspect1.reload.post_ids.should include @post.id
    end
  end

  describe '#aspects_from_ids' do
    it 'returns a list of all valid aspects a alice can post to' do
      aspect_ids = Aspect.all.map(&:id)
      alice.aspects_from_ids(aspect_ids).map{|a| a}.should ==
        alice.aspects.map{|a| a} #RSpec matchers ftw
    end
    it "lets you post to your own aspects" do
      alice.aspects_from_ids([@aspect.id]).should == [@aspect]
      alice.aspects_from_ids([@aspect1.id]).should == [@aspect1]
    end
    it 'removes aspects that are not yours' do
      alice.aspects_from_ids(eve.aspects.first.id).should == []
    end
  end

  describe '#build_post' do
    it 'sets status_message#text' do
      post = alice.build_post(:status_message, :text => "hey", :to => @aspect.id)
      post.text.should == "hey"
    end

    it 'does not save a status_message' do
      post = alice.build_post(:status_message, :text => "hey", :to => @aspect.id)
      post.should_not be_persisted
    end

    it 'does not save a photo' do
      post = alice.build_post(:photo, :user_file => uploaded_photo, :to => @aspect.id)
      post.should_not be_persisted
    end
  end

  describe '#update_post' do
    it 'should update fields' do
      photo = alice.post(:photo, :user_file => uploaded_photo, :text => "Old caption", :to => @aspect.id)
      update_hash = {:text => "New caption"}
      alice.update_post(photo, update_hash)

      photo.text.should match(/New/)
    end
  end
end
