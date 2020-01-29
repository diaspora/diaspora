# frozen_string_literal: true

require_relative "api_spec_helper"

describe Api::V1::TagFollowingsController do
  let(:auth) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid tags:read tags:modify]
    )
  }

  let(:auth_read_only) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid tags:read]
    )
  }

  let(:auth_minimum_scopes) { FactoryGirl.create(:auth_with_default_scopes) }
  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }
  let!(:access_token_minimum_scopes) { auth_minimum_scopes.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  before do
    @expected_tags = %w[tag1 tag2 tag3]
    @expected_tags.each {|tag| add_tag(tag, auth.user) }
    @expected_tags.each {|tag| add_tag(tag, auth_read_only.user) }
    @initial_count = @expected_tags.length
  end

  describe "#create" do
    context "valid tag ID" do
      it "succeeds in adding a tag" do
        post(
          api_v1_tag_followings_path,
          params: {name: "tag4", access_token: access_token}
        )
        expect(response.status).to eq(204)

        get(
          api_v1_tag_followings_path,
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        items = JSON.parse(response.body)
        expect(items.length).to eq(@initial_count + 1)
      end
    end

    context "missing name parameter" do
      it "fails to add" do
        post(
          api_v1_tag_followings_path,
          params: {access_token: access_token}
        )

        confirm_api_error(response, 422, "Failed to process the tag followings request")
      end
    end

    context "duplicate tag" do
      it "fails to add" do
        post(
          api_v1_tag_followings_path,
          params: {name: "tag3", access_token: access_token}
        )

        confirm_api_error(response, 409, "Already following this tag")
      end
    end

    context "fails with credentials" do
      it "insufficient scopes in token" do
        post(
          api_v1_tag_followings_path,
          params: {name: "tag4", access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end

      it "invalid token" do
        post(
          api_v1_tag_followings_path,
          params: {name: "tag4", access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#index" do
    context "list all followed tags" do
      it "succeeds" do
        get(
          api_v1_tag_followings_path,
          params: {access_token: access_token_read_only}
        )
        expect(response.status).to eq(200)
        items = JSON.parse(response.body)
        expect(items.length).to eq(@expected_tags.length)
        @expected_tags.each {|tag| expect(items.find(tag)).to be_truthy }

        expect(items.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/tags")
      end
    end

    context "fails with credentials" do
      it "insufficient scopes in token" do
        get(
          api_v1_tag_followings_path,
          params: {access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(403)
      end

      it "invalid token" do
        get(
          api_v1_tag_followings_path,
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#delete" do
    context "valid tag" do
      it "succeeds in deleting tag" do
        delete(
          api_v1_tag_following_path("tag1"),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)

        get(
          api_v1_tag_followings_path,
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        items = JSON.parse(response.body)
        expect(items.length).to eq(@initial_count - 1)
      end
    end

    context "tag that's not followed" do
      it "does nothing" do
        delete(
          api_v1_tag_following_path(SecureRandom.uuid.to_s),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 410, "Not following this tag")

        get(
          api_v1_tag_followings_path,
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        items = JSON.parse(response.body)
        expect(items.length).to eq(@initial_count)
      end
    end

    context "fails with credentials" do
      it "insufficient scopes in token" do
        delete(
          api_v1_tag_following_path("tag1"),
          params: {access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end

      it "invalid token" do
        delete(
          api_v1_tag_following_path("tag1"),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  private

  def add_tag(name, user)
    tag = ActsAsTaggableOn::Tag.find_or_create_by(name: name)
    tag_following = user.tag_followings.new(tag_id: tag.id)
    tag_following.save
    tag_following
  end
end
