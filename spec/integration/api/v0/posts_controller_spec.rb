require "spec_helper"

describe Api::V0::PostsController, type: :request do
  let!(:auth_with_read) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token_with_read) { auth_with_read.create_access_token.to_s }
  let(:auth_with_read_and_write) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token_with_read_and_write) { auth_with_read_and_write.create_access_token.to_s }

  describe "#show" do
    before do
      @status = auth_with_read_and_write.user.post(:status_message, text: "hello", public: true, to: "all")
    end
    it "succeeds with read token" do
      get api_v0_post_path(id: @status.id), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("hello")
    end
    it "returns record not found with nonexistent post id" do
      get api_v0_post_path(id: "9999"), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("Record not found")
    end
    it "returns unauthorized without token" do
      get api_v0_post_path(id: @status.id), {},
          "Content-Type": "application/vnd.api+json"
      expect(response.body).to include("Unauthorized")
    end
  end

  describe "#create" do
    it "creates a public post" do
      post api_v0_posts_path,
           ({
             data: {
               type:       "posts",
               attributes: {
                 "raw-message": "Hello this is a public post!",
                 aspect_ids:    "public",
                 public:        true,
                 pending:       false
               }
             }
           }).to_json,
           "Content-Type": "application/vnd.api+json",
           Authorization:  "Bearer " + access_token_with_read_and_write
      expect(Post.find_by(text: "Hello this is a public post!").public).to eq(true)
    end

    it "creates a private post" do
      @aspect = auth_with_read_and_write.user.aspects.first
      post api_v0_posts_path,
           ({
             data: {
               type:       "posts",
               attributes: {
                 "raw-message": "Hello this is a private post!",
                 aspect_ids:    @aspect.id,
                 public:        false,
                 pending:       false
               }
             }
           }).to_json,
           "Content-Type": "application/vnd.api+json",
           Authorization:  "Bearer " + access_token_with_read_and_write
      expect(Post.find_by(text: "Hello this is a private post!").public).to eq(false)
    end

    it "returns forbidden with a read only access token" do
      post api_v0_posts_path,
           ({
             data: {
               type:       "posts",
               attributes: {
                 "raw-message": "Hello this is a public post!",
                 aspect_ids:    "public",
                 public:        true,
                 pending:       false
               }
             }
           }).to_json,
           "Content-Type": "application/vnd.api+json",
           Authorization:  "Bearer " + access_token_with_read
      expect(response.body).to include("Forbidden")
    end

    it "returns unauthorized without token" do
      post api_v0_posts_path,
           ({
             data: {
               type:       "posts",
               attributes: {
                 "raw-message": "Hello this is a public post!",
                 aspect_ids:    "public",
                 public:        true,
                 pending:       false
               }
             }
           }).to_json,
           "Content-Type": "application/vnd.api+json"
      expect(response.body).to include("Unauthorized")
    end
  end

  describe "#show_relationship" do
    before do
      @status = auth_with_read_and_write.user.post(:status_message, text: "hello", public: true, to: "all")
    end
    it "succeeds with read token" do
      get api_v0_post_relationships_author_path(post_id: @status.id), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("people")
      expect(response.body).to include(@status.author.id.to_s)
    end

    it "returns record not found with nonexistent post id" do
      get api_v0_post_relationships_author_path(post_id: "9999"), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("Record not found")
    end

    it "returns unauthorized without token" do
      get api_v0_post_relationships_author_path(post_id: @status.id), {},
          "Content-Type": "application/vnd.api+json"
      expect(response.body).to include("Unauthorized")
    end
  end

  # TODO: Add test to verify that only posts that are visible from the current user are accessible
  describe "#get_related_resources" do
    before do
      @status = auth_with_read_and_write.user.post(:status_message, text: "hello", public: true, to: "all")
    end

    it "succeeds with diaspora handle" do
      get api_v0_person_posts_path(person_id: @status.author.diaspora_handle), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("posts")
      expect(response.body).to include(@status.id.to_s)
    end

    it "succeeds with guid" do
      get api_v0_person_posts_path(person_id: @status.author.guid), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("posts")
      expect(response.body).to include(@status.id.to_s)
    end

    it "returns record not found with nonexistent person id" do
      get api_v0_person_posts_path(person_id: 9999), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("Record not found")
    end

    it "returns unauthorized without token" do
      get api_v0_person_posts_path(person_id: @status.author.id), {},
          "Content-Type": "application/vnd.api+json"
      expect(response.body).to include("Unauthorized")
    end
  end
end
