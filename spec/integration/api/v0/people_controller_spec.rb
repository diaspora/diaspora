require "spec_helper"

describe Api::V0::PeopleController, type: :request do
  let!(:auth_with_read) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token_with_read) { auth_with_read.create_access_token.to_s }
  let(:auth_with_read_and_write) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token_with_read_and_write) { auth_with_read_and_write.create_access_token.to_s }

  describe "#show" do
    before do
      @person = auth_with_read_and_write.user.person
    end

    it "succeeds with guid" do
      get api_v0_person_path(id: @person.guid), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("people")
      expect(response.body).to include(@person.id.to_s)
    end

    it "succeeds with diaspora_handle" do
      get api_v0_person_path(id: @person.diaspora_handle), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("people")
      expect(response.body).to include(@person.id.to_s)
    end

    it "returns record not found with nonexistent person id" do
      get api_v0_person_path(id: "9999"), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("Record not found")
    end

    it "returns unauthorized without token" do
      get api_v0_person_path(id: @person.guid), {},
          "Content-Type": "application/vnd.api+json"
      expect(response.body).to include("Unauthorized")
    end
  end

  describe "#get_related_resources" do
    before do
      @status = auth_with_read_and_write.user.post(:status_message, text: "hello", public: true, to: "all")
    end

    it "succeeds with id" do
      get api_v0_post_author_path(post_id: @status.id), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("people")
      expect(response.body).to include(@status.author.id.to_s)
    end

    it "succeeds with guid" do
      get api_v0_post_author_path(post_id: @status.guid), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("people")
      expect(response.body).to include(@status.author.id.to_s)
    end

    it "returns record not found with nonexistent post id" do
      get api_v0_post_author_path(post_id: 9999), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("Record not found")
    end

    it "returns unauthorized without token" do
      get api_v0_post_author_path(post_id: @status.id), {},
          "Content-Type": "application/vnd.api+json"
      expect(response.body).to include("Unauthorized")
    end
  end

  describe "#show_relationship" do
    before do
      @status = auth_with_read_and_write.user.post(:status_message, text: "hello", public: true, to: "all")
    end

    it "succeeds" do
      get api_v0_person_relationships_posts_path(person_id: @status.author.guid), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("posts")
      expect(response.body).to include(@status.id.to_s)
    end

    it "returns record not found with nonexistent person id" do
      get api_v0_person_relationships_posts_path(person_id: "9999"), {},
          "Content-Type": "application/vnd.api+json", Authorization: "Bearer " + access_token_with_read
      expect(response.body).to include("Record not found")
    end

    it "returns unauthorized without token" do
      get api_v0_person_relationships_posts_path(person_id: @status.author.guid), {},
          "Content-Type": "application/vnd.api+json"
      expect(response.body).to include("Unauthorized")
    end
  end
end
