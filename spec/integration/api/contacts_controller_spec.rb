# frozen_string_literal: true

require_relative "api_spec_helper"

describe Api::V1::ContactsController do
  let(:auth) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid contacts:read contacts:modify]
    )
  }

  let(:auth_read_only) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid contacts:read]
    )
  }

  let(:auth_minimum_scopes) {
    FactoryGirl.create(:auth_with_default_scopes)
  }

  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }
  let!(:access_token_minimum_scopes) { auth_minimum_scopes.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  before do
    @aspect1 = auth.user.aspects.create(name: "generic")
    auth.user.share_with(eve.person, @aspect1)
    @aspect2 = auth.user.aspects.create(name: "another aspect")
    @eve_aspect = eve.aspects.first
    alice.person.profile = FactoryGirl.create(:profile_with_image_url)
  end

  describe "#show" do
    before do
      aspects_membership_service.create(@aspect2.id, alice.person.id)
    end

    context "for valid aspect" do
      it "lists members" do
        get(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        contacts = response_body_data(response)
        expect(contacts.length).to eq(1)
        confirm_person_format(contacts[0], alice)

        get(
          api_v1_aspect_contacts_path(@aspect1.id),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        contacts = response_body_data(response)
        expect(contacts.length).to eq(@aspect1.contacts.length)

        expect(contacts.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/users")
      end
    end

    context "for invalid aspect" do
      it "fails for non-existant Aspect ID" do
        get(
          api_v1_aspect_contacts_path(-1),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Aspect with provided ID could not be found")
      end

      it "fails for other user's Aspect ID" do
        get(
          api_v1_aspect_contacts_path(@eve_aspect.id),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Aspect with provided ID could not be found")
      end
    end

    context "improper credentials" do
      it "fails without contacts:read" do
        aspect = auth_minimum_scopes.user.aspects.create(name: "new aspect")
        get(
          api_v1_aspect_contacts_path(aspect.id),
          params: {access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(403)
      end

      it "fails when not logged in" do
        get(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#create" do
    context "with valid person GUID and aspect" do
      it "succeeds adding" do
        post(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {person_guid: alice.guid, access_token: access_token}
        )
        expect(response.status).to eq(204)
        expect(@aspect2.contacts.length).to eq(1)
      end

      it "fails if re-adding" do
        aspects_membership_service.create(@aspect2.id, alice.person.id)
        post(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {person_guid: alice.guid, access_token: access_token}
        )
        confirm_api_error(response, 422, "Failed to add user to aspect")
      end
    end

    context "with invalid Aspect" do
      it "fails for non-existant Aspect ID" do
        post(
          api_v1_aspect_contacts_path(-1),
          params: {person_guid: alice.guid, access_token: access_token}
        )
        confirm_api_error(response, 404, "Aspect with provided ID could not be found")
      end

      it "fails for other user's Aspect ID" do
        post(
          api_v1_aspect_contacts_path(@eve_aspect.id),
          params: {person_guid: alice.guid, access_token: access_token}
        )
        confirm_api_error(response, 404, "Aspect with provided ID could not be found")
      end
    end

    context "with invalid person GUID" do
      it "fails to add" do
        post(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {person_guid: "999_999_999", access_token: access_token}
        )
        confirm_api_error(response, 422, "Failed to add user to aspect")
      end
    end

    context "improper credentials" do
      it "fails when not logged in" do
        post(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {person_guid: alice.guid, access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end

      it "fails when only read only token" do
        post(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {person_guid: alice.guid, access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#destroy" do
    before do
      aspects_membership_service.create(@aspect2.id, alice.person.id)
    end

    context "with valid person GUID and aspect" do
      it "succeeds deleting" do
        delete(
          api_v1_aspect_contact_path(@aspect2.id, alice.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)
        expect(@aspect2.contacts.length).to eq(0)
      end

      it "fails if not in aspect" do
        delete(
          api_v1_aspect_contact_path(@aspect2.id, eve.guid),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Aspect or contact on aspect not found")
      end
    end

    context "with invalid Aspect" do
      it "fails for non-existant Aspect ID" do
        delete(
          api_v1_aspect_contact_path(-1, eve.guid),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Aspect or contact on aspect not found")
      end

      it "fails for other user's Aspect ID" do
        delete(
          api_v1_aspect_contact_path(@eve_aspect.id, eve.guid),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Aspect or contact on aspect not found")
      end
    end

    context "with invalid person GUID" do
      it "fails to delete " do
        delete(
          api_v1_aspect_contact_path(@aspect2.id, "999_999_999"),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 422, "Failed to remove user from aspect")
      end
    end

    context "improper credentials" do
      it "fails when not logged in" do
        delete(
          api_v1_aspect_contact_path(@aspect2.id, alice.guid),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end

      it "fails when only read only token" do
        aspect = auth_read_only.user.aspects.create(name: "new")
        aspects_membership_service(auth_read_only.user).create(aspect.id, alice.person.id)
        delete(
          api_v1_aspect_contact_path(aspect.id, alice.guid),
          params: {access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end
    end
  end

  def response_body_data(response)
    JSON.parse(response.body)
  end

  def aspects_membership_service(user=auth.user)
    AspectsMembershipService.new(user)
  end

  # rubocop:disable Metrics/AbcSize
  def confirm_person_format(post_person, user)
    expect(post_person["guid"]).to eq(user.guid)
    expect(post_person["diaspora_id"]).to eq(user.diaspora_handle)
    expect(post_person["name"]).to eq(user.name)
    expect(post_person["avatar"]).to eq(user.profile.image_url(size: :thumb_medium))
  end
  # rubocop:enable Metrics/AbcSize
end
