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

  describe "#destroy" do
    before do
      @like = alice.like!(@status)
    end

    it "should delete a participation" do
      expect { @like.destroy }.to change { Participation.count }.by(-1)
    end

    it "should decrease count participation" do
      alice.comment!(@status, "Are you there?")
      @like.destroy
      participations = Participation.where(target_id: @like.target_id, author_id: @like.author_id)
      expect(participations.first.count).to eq(1)
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
