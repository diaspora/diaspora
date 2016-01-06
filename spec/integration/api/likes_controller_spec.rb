require "spec_helper"

describe Api::V0::LikesController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }

  before do
    @status = auth.user.post(:status_message, text: "This is a status message", public: true, to: "all")
  end

  describe "#create" do
    it "returns the expected author" do
      post api_v0_post_likes_path(post_id: @status.id), access_token: access_token
      json = JSON.parse(response.body)
      expect(json["author"]["id"]).to eq(auth.user.person.id)
    end

    it "fails on random post id" do
      post api_v0_post_likes_path(post_id: 9999999), access_token: access_token
      expect(response.body).to eq("Post or like not found")
    end
  end

  describe "#delete" do
    before do
      post api_v0_post_likes_path(post_id: @status.id), access_token: access_token
      @like_id = JSON.parse(response.body)["id"]
    end

    it "succeeds" do
      delete api_v0_post_like_path(post_id: @status.id, id: @like_id), access_token: access_token
      expect(response).to be_success
    end

    it "fails on random like id" do
      delete api_v0_post_like_path(post_id: @status.id, id: 99999999), access_token: access_token
      expect(response.body).to eq("Post or like not found")
    end
  end
end
