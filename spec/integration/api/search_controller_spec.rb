# frozen_string_literal: true

require_relative "api_spec_helper"

describe Api::V1::SearchController do
  let(:auth) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify private:read contacts:read private:modify]
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
      tag = SecureRandom.hex(5)
      5.times do
        FactoryGirl.create(:person, profile: FactoryGirl.build(:profile, tag_string: "##{tag}"))
      end
      FactoryGirl.create(:person, closed_account: true, profile: FactoryGirl.build(:profile, tag_string: "##{tag}"))

      get(
        "/api/v1/search/users",
        params: {tag: tag, access_token: access_token}
      )
      expect(response.status).to eq(200)
      users = response_body_data(response)
      expect(users.length).to eq(5)

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

    context "with a contacts filter" do
      let(:name) { "A contact" }

      it "only returns contacts" do
        add_contact(true, false)
        add_contact(false, true)
        add_contact(true, true)

        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: name,
            filter:         "contacts",
            access_token:   access_token
          }
        )

        expect(response.status).to eq(200)
        users = response_body_data(response)
        expect(users.length).to eq(3)
      end

      it "only returns receiving contacts" do
        add_contact(true, false)
        add_contact(true, false)
        add_contact(false, true)

        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: name,
            filter:         "contacts:receiving",
            access_token:   access_token
          }
        )

        expect(response.status).to eq(200)
        users = response_body_data(response)
        expect(users.length).to eq(2)
      end

      it "only returns sharing contacts" do
        add_contact(true, false)
        add_contact(false, true)
        add_contact(false, true)

        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: name,
            filter:         "contacts:sharing",
            access_token:   access_token
          }
        )

        expect(response.status).to eq(200)
        users = response_body_data(response)
        expect(users.length).to eq(2)
      end

      it "only returns mutually sharing contacts" do
        add_contact(true, false)
        add_contact(false, true)
        add_contact(true, true)

        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: name,
            filter:         ["contacts:receiving", "contacts:sharing"],
            access_token:   access_token
          }
        )

        expect(response.status).to eq(200)
        users = response_body_data(response)
        expect(users.length).to eq(1)
      end

      it "fails with an invalid filter" do
        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: name,
            filter:         "contacts:thingsiwant",
            access_token:   access_token
          }
        )

        confirm_api_error(response, 422, "Invalid filter")
      end

      it "fails without contacts:read scope" do
        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: name,
            filter:         "contacts",
            access_token:   access_token_read_only
          }
        )

        confirm_api_error(response, 403, "insufficient_scope")
      end

      def add_contact(receiving, sharing)
        other = FactoryGirl.create(:user)
        other.profile.update(first_name: name)

        if receiving
          aspect = auth.user.aspects.find_or_create_by(name: "Test")
          auth.user.share_with(other.person, aspect)
        end

        if sharing # rubocop:disable Style/GuardClause
          aspect = other.aspects.create(name: "Test")
          other.share_with(auth.user.person, aspect)
        end
      end
    end

    context "with an aspects filter" do
      let(:contact_name) { "My aspect contact" }
      let(:aspect) { auth.user.aspects.create(name: "Test") }
      let(:second_aspect) { auth.user.aspects.create(name: "Second test") }

      it "only returns members of given aspects" do
        add_contact(aspect)
        add_contact(second_aspect)

        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: contact_name,
            filter:         "aspect:#{aspect.id}",
            access_token:   access_token
          }
        )

        expect(response.status).to eq(200)
        users = response_body_data(response)
        expect(users.length).to eq(1)

        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: contact_name,
            filter:         "aspect:#{aspect.id},#{second_aspect.id}",
            access_token:   access_token
          }
        )

        expect(response.status).to eq(200)
        users = response_body_data(response)
        expect(users.length).to eq(2)
      end

      it "only returns people matching all aspect filters" do
        add_contact(aspect)
        add_contact(second_aspect)
        add_contact(aspect, second_aspect)

        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: contact_name,
            filter:         ["aspect:#{aspect.id}", "aspect:#{second_aspect.id}"],
            access_token:   access_token
          }
        )

        expect(response.status).to eq(200)
        users = response_body_data(response)
        expect(users.length).to eq(1)
      end

      it "fails with an invalid aspect" do
        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: contact_name,
            filter:         "aspect:0",
            access_token:   access_token
          }
        )

        confirm_api_error(response, 422, "Invalid aspect filter")

        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: contact_name,
            filter:         "aspect:#{aspect.id},0",
            access_token:   access_token
          }
        )

        confirm_api_error(response, 422, "Invalid aspect filter")
      end

      it "fails without contacts:read scope" do
        aspect = auth_read_only.user.aspects.create(name: "Test")

        get(
          "/api/v1/search/users",
          params: {
            name_or_handle: contact_name,
            filter:         "aspect:#{aspect.id}",
            access_token:   access_token_read_only
          }
        )

        confirm_api_error(response, 403, "insufficient_scope")
      end

      def add_contact(*aspects)
        other = FactoryGirl.create(:person, profile: FactoryGirl.build(:profile, first_name: contact_name))
        aspects.each do |aspect|
          auth.user.share_with(other, aspect)
        end
      end
    end

    it "fails with an invalid filter" do
      get(
        "/api/v1/search/users",
        params: {
          name_or_handle: "findable",
          filter:         "thingsiwant",
          access_token:   access_token
        }
      )

      confirm_api_error(response, 422, "Invalid filter")
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
      confirm_api_error(response, 422, "Parameters tag and name_or_handle are exclusive")
    end

    it "fails with no fields" do
      get(
        "/api/v1/search/users",
        params: {access_token: access_token}
      )
      confirm_api_error(response, 422, "Missing parameter tag or name_or_handle")
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
      confirm_api_error(response, 422, "param is missing or the value is empty: tag")
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
      confirm_api_error(response, 422, "param is missing or the value is empty: query")
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
