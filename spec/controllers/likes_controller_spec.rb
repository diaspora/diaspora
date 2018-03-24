# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe LikesController, type: :controller do
  before do
    @alices_aspect = alice.aspects.where(:name => "generic").first
    @bobs_aspect = bob.aspects.where(:name => "generic").first

    sign_in(alice, scope: :user)
  end

  describe "#create" do
    let(:like_hash) {
      {post_id: @target.id}
    }

    context "on my own post" do
      it "succeeds" do
        @target = alice.post :status_message, text: "AWESOME", to: @alices_aspect.id
        post :create, params: like_hash, format: :json
        expect(response.code).to eq("201")
      end
    end

    context "on a post from a contact" do
      before do
        @target = bob.post(:status_message, text: "AWESOME", to: @bobs_aspect.id)
      end

      it "likes" do
        post :create, params: like_hash
        expect(response.code).to eq("201")
      end

      it "doesn't post multiple times" do
        alice.like!(@target)
        post :create, params: like_hash
        expect(response.code).to eq("422")
      end
    end

    context "on a post from a stranger" do
      before do
        @target = eve.post :status_message, text: "AWESOME", to: eve.aspects.first.id
      end

      it "doesn't post" do
        expect(alice).not_to receive(:like!)
        post :create, params: like_hash
        expect(response.code).to eq("422")
      end
    end

    context "when an the exception is raised" do
      before do
        @target = alice.post :status_message, text: "AWESOME", to: @alices_aspect.id
      end

      it "should be catched when it means that the target is not found" do
        post :create, params: {post_id: -1}, format: :json
        expect(response.code).to eq("422")
      end

      it "should not be catched when it is unexpected" do
        @target = alice.post :status_message, text: "AWESOME", to: @alices_aspect.id
        allow(alice).to receive(:like!).and_raise("something")
        allow(@controller).to receive(:current_user).and_return(alice)
        expect { post :create, params: like_hash, format: :json }.to raise_error("something")
      end
    end
  end

  describe "#index" do
    before do
      @message = alice.post(:status_message, text: "hey", to: @alices_aspect.id)
    end

    it "returns a 404 for a post not visible to the user" do
      sign_in eve
      expect {
        get :index, params: {post_id: @message.id}
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an array of likes for a post" do
      bob.like!(@message)
      get :index, params: {post_id: @message.id}
      expect(JSON.parse(response.body).map {|h| h["id"] }).to match_array(@message.likes.map(&:id))
    end

    it "returns an empty array for a post with no likes" do
      get :index, params: {post_id: @message.id}
      expect(JSON.parse(response.body)).to eq([])
    end

    it "returns likes for a public post without login" do
      post = alice.post(:status_message, text: "hey", public: true)
      bob.like!(post)
      sign_out :user
      get :index, params: {post_id: post.id}, format: :json
      expect(JSON.parse(response.body).map {|h| h["id"] }).to match_array(post.likes.map(&:id))
    end

    it "returns a 401 for a private post when logged out" do
      bob.like!(@message)
      sign_out :user
      get :index, params: {post_id: @message.id}, format: :json
      expect(response.status).to eq(401)
    end
  end

  describe "#destroy" do
    before do
      @message = bob.post(:status_message, text: "hey", to: @alices_aspect.id)
      @like = alice.like!(@message)
    end

    it "lets a user destroy their like" do
      current_user = controller.send(:current_user)
      expect(current_user).to receive(:retract).with(@like)

      delete :destroy, params: {post_id: @message.id, id: @like.id}, format: :json
      expect(response.status).to eq(204)
    end

    it "does not let a user destroy other likes" do
      like2 = eve.like!(@message)
      like_count = Like.count

      delete :destroy, params: {post_id: @message.id, id: like2.id}, format: :json
      expect(response.status).to eq(404)
      expect(response.body).to eq(I18n.t("likes.destroy.error"))
      expect(Like.count).to eq(like_count)
    end
  end
end
