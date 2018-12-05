# frozen_string_literal: true

require "spec_helper"

describe Api::V1::SearchController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }
  let(:auth_read_only) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }

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
      expect(users.length).to eq(14)
    end

    it "succeeds by name" do
      get(
        "/api/v1/search/users",
        params: {name_or_handle: "Terry", access_token: access_token}
      )
      expect(response.status).to eq(200)
      users = response_body_data(response)
      expect(users.length).to eq(1)
    end

    it "succeeds by handle" do
      get(
        "/api/v1/search/users",
        params: {name_or_handle: "findable", access_token: access_token}
      )
      expect(response.status).to eq(200)
      users = response_body_data(response)
      expect(users.length).to eq(1)
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

    it "fails if ask for both" do
      get(
        "/api/v1/search/users",
        params: {tag: "tag1", name_or_handle: "name", access_token: access_token}
      )
      expect(response.status).to eq(422)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.search.cant_process"))
    end

    it "fails with no fields" do
      get(
        "/api/v1/search/users",
        params: {access_token: access_token}
      )
      expect(response.status).to eq(422)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.search.cant_process"))
    end

    it "fails with bad credentials" do
      get(
        "/api/v1/search/users",
        params: {tag: "tag1", access_token: "999_999_999"}
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
    end

    it "succeeds by tag" do
      get(
        "/api/v1/search/posts",
        params: {tag: "tag2", access_token: access_token}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)
      expect(posts.length).to eq(2)
    end

    it "fails with missing parameters" do
      get(
        "/api/v1/search/posts",
        params: {access_token: access_token}
      )
      expect(response.status).to eq(422)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.search.cant_process"))
    end

    it "fails with bad credentials" do
      get(
        "/api/v1/search/users",
        params: {tag: "tag1", access_token: "999_999_999"}
      )
      expect(response.status).to eq(401)
    end
  end

  def response_body_data(response)
    JSON.parse(response.body)["data"]
  end
end
