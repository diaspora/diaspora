# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe User, :type => :model do
  before do
    @aspect = alice.aspects.first
    @aspect1 = alice.aspects.create(:name => 'other')
  end

  describe '#add_to_streams' do
    before do
      @post = alice.build_post(:status_message, text: "hey")
      @post.save
      @aspect_ids = [@aspect.id, @aspect1.id]
      @aspects = alice.aspects_from_ids(@aspect_ids)
    end

    it 'saves post into visible post ids' do
      expect {
        alice.add_to_streams(@post, @aspects)
      }.to change { alice.visible_shareables(Post, by_members_of: @aspect_ids).length }.by(1)
      expect(alice.visible_shareables(Post, by_members_of: @aspect_ids)).to include @post
    end

    it 'saves post into each aspect in aspect_ids' do
      alice.add_to_streams(@post, @aspects)
      expect(@aspect.reload.post_ids).to include @post.id
      expect(@aspect1.reload.post_ids).to include @post.id
    end
  end

  describe '#aspects_from_ids' do
    it 'returns a list of all valid aspects a alice can post to' do
      aspect_ids = Aspect.all.map(&:id)
      expect(alice.aspects_from_ids(aspect_ids).map{|a| a}).to eq(
        alice.aspects.map{|a| a}
      ) #RSpec matchers ftw
    end
    it "lets you post to your own aspects" do
      expect(alice.aspects_from_ids([@aspect.id])).to eq([@aspect])
      expect(alice.aspects_from_ids([@aspect1.id])).to eq([@aspect1])
    end
    it 'removes aspects that are not yours' do
      expect(alice.aspects_from_ids(eve.aspects.first.id)).to eq([])
    end
  end

  describe '#build_post' do
    it 'sets status_message#text' do
      post = alice.build_post(:status_message, :text => "hey", :to => @aspect.id)
      expect(post.text).to eq("hey")
    end

    it 'does not save a status_message' do
      post = alice.build_post(:status_message, :text => "hey", :to => @aspect.id)
      expect(post).not_to be_persisted
    end

    it 'does not save a photo' do
      post = alice.build_post(:photo, :user_file => uploaded_photo, :to => @aspect.id)
      expect(post).not_to be_persisted
    end
  end

  describe '#update_post' do
    it 'should update fields' do
      photo = alice.post(:photo, :user_file => uploaded_photo, :text => "Old caption", :to => @aspect.id)
      update_hash = {:text => "New caption"}
      alice.update_post(photo, update_hash)

      expect(photo.text).to match(/New/)
    end
  end
end
