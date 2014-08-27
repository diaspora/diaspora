#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require Rails.root.join("spec", "shared_behaviors", "relayable")

describe Like, :type => :model do
  before do
    @status = bob.post(:status_message, :text => "hello", :to => bob.aspects.first.id)
  end

  it 'has a valid factory' do
    expect(FactoryGirl.build(:like)).to be_valid
  end

  describe '#notification_type' do
    before do
      @like = alice.like!(@status)
    end

    it 'should be notifications liked if you are the post owner' do
      expect(@like.notification_type(bob, alice.person)).to be Notifications::Liked
    end

    it 'should not notify you if you are the like-r' do
      expect(@like.notification_type(alice, alice.person)).to be_nil
    end

    it 'should not notify you if you did not create the post' do
      expect(@like.notification_type(eve, alice.person)).to be_nil
    end
  end

  describe 'counter cache' do
    it 'increments the counter cache on its post' do
      expect {
        alice.like!(@status)
      }.to change{ @status.reload.likes_count }.by(1)
    end

    it 'increments the counter cache on its comment' do
      comment = FactoryGirl.create(:comment, :post => @status)
      expect {
        alice.like!(comment)
      }.to change{ comment.reload.likes_count }.by(1)
    end
  end

  describe 'xml' do
    before do
      alices_aspect = alice.aspects.first

      @liker = FactoryGirl.create(:user)
      @liker_aspect = @liker.aspects.create(:name => "dummies")
      connect_users(alice, alices_aspect, @liker, @liker_aspect)
      @post = alice.post(:status_message, :text => "huhu", :to => alices_aspect.id)
      @like = @liker.like!(@post)
      @xml = @like.to_xml.to_s
    end
    it 'serializes the sender handle' do
      expect(@xml.include?(@liker.diaspora_handle)).to be true
    end
    it' serializes the post_guid' do
      expect(@xml).to include(@post.guid)
    end
    describe 'marshalling' do
      before do
        @marshalled_like = Like.from_xml(@xml)
      end
      it 'marshals the author' do
        expect(@marshalled_like.author).to eq(@liker.person)
      end
      it 'marshals the post' do
        expect(@marshalled_like.target).to eq(@post)
      end
    end
  end

  describe 'it is relayable' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @remote_parent = FactoryGirl.create(:status_message, :author => @remote_raphael)
      @local_parent = @local_luke.post :status_message, :text => "foobar", :to => @local_luke.aspects.first

      @object_by_parent_author = @local_luke.like!(@local_parent)
      @object_by_recipient = @local_leia.like!(@local_parent)
      @dup_object_by_parent_author = @object_by_parent_author.dup

      @object_on_remote_parent = @local_luke.like!(@remote_parent)
    end

    let(:build_object) { Like::Generator.new(alice, @status).build }
    it_should_behave_like 'it is relayable'
  end
end
