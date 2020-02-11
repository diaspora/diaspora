# frozen_string_literal: true

require_relative "api_spec_helper"

describe Api::V1::SearchController do
  let(:auth) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify private:read private:modify]
    )
  }

  let(:auth_read_only) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read private:read]
    )
  }

  let(:auth_public_only_read_only) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read]
    )
  }

  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }
  let!(:access_token_public_only_read_only) { auth_public_only_read_only.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  describe "#user_index" do
    before do
      @searchable_user = FactoryGirl.create(
        :person,
        diaspora_handle: "findable@example.org",
        profile:         FactoryGirl.build(:profile, first_name: "Terry", last_name: "Smith")
      )

      @closed_user = FactoryGirl.create(
        :person,
        closed_account: true,
        profile:        FactoryGirl.build(:profile, first_name: "Closed", last_name: "Account")
      )
      @unsearchable_user = FactoryGirl.create(
        :person,
        diaspora_handle: "unsearchable@example.org",
        profile:         FactoryGirl.build(
          :profile,
          first_name: "Unsearchable",
          last_name:  "Person",
          searchable: false
        )
      )
    end

    it "succeeds by tag" do
      get(
        "/api/v1/search/users",
        params: {tag: "one", access_token: access_token}
      )
      expect(response.status).to eq(200)
      users = response_body_data(response)
      expect(users.length).to eq(15)

      expect(users.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/users")
    end

    it "succeeds by name" do
      get(
        "/api/v1/search/users",
        params: {name_or_handle: "Terry", access_token: access_token}
      )
      expect(response.status).to eq(200)
      users = response_body_data(response)
      expect(users.length).to eq(1)

      expect(users.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/users")
    end

    it "succeeds by handle" do
      get(
        "/api/v1/search/users",
        params: {name_or_handle: "findable", access_token: access_token}
      )
      expect(response.status).to eq(200)
      users = response_body_data(response)
      expect(users.length).to eq(1)

      expect(users.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/users")
    end

    it "doesn't return closed accounts" do
      get(
        "/api/v1/search/users",
        params: {name_or_handle: "Closed", access_token: access_token}
      )
      expect(response.status).to eq(200)
      users = response_body_data(response)
      expect(users.length).to eq(0)
    end

    it "doesn't return hidden accounts" do
      get(
        "/api/v1/search/users",
        params: {name_or_handle: "unsearchable@example.org", access_token: access_token}
      )
      expect(response.status).to eq(200)
      users = response_body_data(response)
      expect(users.length).to eq(0)
    end

    it "doesn't return hidden accounts who are linked without contacts:read token" do
      aspect_to = auth_public_only_read_only.user.aspects.create(name: "shared aspect")
      auth_public_only_read_only.user.share_with(@unsearchable_user, aspect_to)

      get(
        "/api/v1/search/users",
        params: {name_or_handle: "unsearchable@example.org", access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      users = response_body_data(response)
      expect(users.length).to eq(0)
    end

    it "fails if ask for both" do
      get(
        "/api/v1/search/users",
        params: {tag: "tag1", name_or_handle: "name", access_token: access_token}
      )
      confirm_api_error(response, 422, "Search request could not be processed")
    end

    it "fails with no fields" do
      get(
        "/api/v1/search/users",
        params: {access_token: access_token}
      )
      confirm_api_error(response, 422, "Search request could not be processed")
    end

    it "fails with bad credentials" do
      get(
        "/api/v1/search/users",
        params: {tag: "tag1", access_token: invalid_token}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "post_index" do
    before do
      @user_post = auth.user.post(
        :status_message,
        text:   "This is a status message #tag1 #tag2",
        public: true
      )

      @eve_post = eve.post(
        :status_message,
        text:   "This is Eve's status message #tag2 #tag3",
        public: true
      )

      aspect = eve.aspects.create(name: "shared aspect")
      eve.share_with(auth_public_only_read_only.user.person, aspect)
      eve.share_with(auth.user.person, aspect)
      @eve_private_post = eve.post(
        :status_message,
        text:   "This is Eve's status message #tag2 #tag3",
        public: false,
        to:     aspect.id
      )
    end

    it "succeeds by tag" do
      get(
        "/api/v1/search/posts",
        params: {tag: "tag2", access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)
      expect(posts.length).to eq(2)

      expect(posts.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/posts")
    end

    it "only returns public posts without private scope" do
      get(
        "/api/v1/search/posts",
        params: {tag: "tag2", access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)
      expect(posts.length).to eq(2)

      get(
        "/api/v1/search/posts",
        params: {tag: "tag2", access_token: access_token}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)
      expect(posts.length).to eq(3)
    end

    it "fails with missing parameters" do
      get(
        "/api/v1/search/posts",
        params: {access_token: access_token}
      )
      confirm_api_error(response, 422, "Search request could not be processed")
    end

    it "fails with bad credentials" do
      get(
        "/api/v1/search/posts",
        params: {tag: "tag1", access_token: invalid_token}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "tag_index" do
    before do
      FactoryGirl.create(:tag, name: "apipartyone")
      FactoryGirl.create(:tag, name: "apipartytwo")
      FactoryGirl.create(:tag, name: "apipartythree")
    end

    it "succeeds" do
      get(
        "/api/v1/search/tags",
        params: {query: "apiparty", access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      tags = response_body_data(response)
      expect(tags.size).to eq(3)

      expect(tags.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/tags")
    end

    it "does a prefix search" do
      get(
        "/api/v1/search/tags",
        params: {query: "apipartyt", access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      tags = response_body_data(response)
      expect(tags.size).to eq(2)

      expect(tags.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/tags")
    end

    it "fails with missing parameters" do
      get(
        "/api/v1/search/tags",
        params: {access_token: access_token}
      )
      confirm_api_error(response, 422, "Search request could not be processed")
    end

    it "fails with bad credentials" do
      get(
        "/api/v1/search/tags",
        params: {query: "apiparty", access_token: invalid_token}
      )
      expect(response.status).to eq(401)
    end
  end

  def response_body_data(response)
    JSON.parse(response.body)
  end
end
