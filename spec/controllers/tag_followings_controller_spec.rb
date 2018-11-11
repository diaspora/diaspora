# frozen_string_literal: true

describe TagFollowingsController, type: :controller do
  describe "#manage" do
    context "not signed in" do
      it "redirects html requests" do
        get :manage
        expect(response).to redirect_to new_user_session_path
      end

      it "redirects mobile requests" do
        get :manage, format: :mobile
        expect(response).to redirect_to new_user_session_path(format: :mobile)
      end
    end
    context "signed in" do
      before do
        sign_in alice, scope: :user
      end

      it "redirects html requests" do
        get :manage
        expect(response).to redirect_to followed_tags_stream_path
      end

      it "does not redirect mobile requests" do
        get :manage, format: :mobile
        expect(response).not_to be_redirect
      end
    end
  end

  describe "#create" do
    before do
      sign_in alice, scope: :user
    end

    it "Creates new tag with valid name" do
      name = SecureRandom.uuid
      post :create, params: {name: name}
      expect(response.status).to be(201)
      tag_data = JSON.parse(response.body)
      expect(tag_data["name"]).to eq(name)
      expect(tag_data.has_key?("id")).to be_truthy
      expect(tag_data["taggings_count"]).to eq(0)
    end

    it "Fails with missing name field" do
      post :create, params: {}
      expect(response.status).to eq(403)
    end
  end

  describe "#destroy" do
    before do
      sign_in alice, scope: :user
      @tag_name = SecureRandom.uuid
      post :create, params: {name: @tag_name}
      @tag_id_to_delete = JSON.parse(response.body)["id"]
    end

    it "Deletes tag with valid id" do
      delete :destroy, params: {id: @tag_id_to_delete}, format: :json
      expect(response.status).to eq(204)
      expect(alice.followed_tags.find_by(name: @tag_name)).to be_nil
    end

    it "Fails with missing name field" do
      delete :create, params: {}, format: :json
      expect(response.status).to eq(403)
    end

    it "Fails with bad Tag ID" do
      delete :create, params: {id: -1}, format: :json
      expect(response.status).to eq(403)
    end
  end

  describe "#index" do
    before do
      sign_in alice, scope: :user
      post :create, params: {name: "tag1"}
      post :create, params: {name: "tag2"}
    end

    it "Gets Tags" do
      get :index, format: :json
      expect(response.status).to eq(200)
      tag_followings = JSON.parse(response.body)
      expect(tag_followings.length).to eq(2)
      expect(tag_followings.find(name: "tag1")).to_not be_nil
      expect(tag_followings.find(name: "tag2")).to_not be_nil
    end
  end
end
