# frozen_string_literal: true

require "spec_helper"

describe Api::V1::ContactsController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let(:auth_read_only) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }

  before do
    @aspect1 = auth.user.aspects.where(name: "generic").first
    @aspect2 = auth.user.aspects.create(name: "another aspect")
    @eve_aspect = eve.aspects.first
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
        contacts = JSON.parse(response.body)
        expect(contacts.length).to eq(1)
        confirm_person_format(contacts[0], alice)

        get(
          api_v1_aspect_contacts_path(@aspect1.id),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        contacts = JSON.parse(response.body)
        expect(contacts.length).to eq(@aspect1.contacts.length)
      end
    end

    context "for invalid aspect" do
      it "fails for non-existant Aspect ID" do
        get(
          api_v1_aspect_contacts_path(-1),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.aspects.not_found"))
      end

      it "fails for other user's Aspect ID" do
        get(
          api_v1_aspect_contacts_path(@eve_aspect.id),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.aspects.not_found"))
      end
    end

    context "improper credentials" do
      it "fails when not logged in" do
        get(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {access_token: "999_999_999"}
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
        expect(response.status).to eq(422)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.contacts.cant_create"))
      end
    end

    context "with invalid Aspect" do
      it "fails for non-existant Aspect ID" do
        post(
          api_v1_aspect_contacts_path(-1),
          params: {person_guid: alice.guid, access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.aspects.not_found"))
      end

      it "fails for other user's Aspect ID" do
        post(
          api_v1_aspect_contacts_path(@eve_aspect.id),
          params: {person_guid: alice.guid, access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.aspects.not_found"))
      end
    end

    context "with invalid person GUID" do
      it "fails to add" do
        post(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {person_guid: "999_999_999", access_token: access_token}
        )
        expect(response.status).to eq(422)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.contacts.cant_create"))
      end
    end

    context "improper credentials" do
      it "fails when not logged in" do
        post(
          api_v1_aspect_contacts_path(@aspect2.id),
          params: {person_guid: alice.guid, access_token: "999_999_999"}
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
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.contacts.not_found"))
      end
    end

    context "with invalid Aspect" do
      it "fails for non-existant Aspect ID" do
        delete(
          api_v1_aspect_contact_path(-1, eve.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.contacts.not_found"))
      end

      it "fails for other user's Aspect ID" do
        delete(
          api_v1_aspect_contact_path(@eve_aspect.id, eve.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.contacts.not_found"))
      end
    end

    context "with invalid person GUID" do
      it "fails to delete " do
        delete(
          api_v1_aspect_contact_path(@aspect2.id, "999_999_999"),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(422)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.contacts.cant_delete"))
      end
    end

    context "improper credentials" do
      it "fails when not logged in" do
        delete(
          api_v1_aspect_contact_path(@aspect2.id, alice.guid),
          params: {access_token: "999_999_999"}
        )
        expect(response.status).to eq(401)
      end

      it "fails when only read only token" do
        delete(
          api_v1_aspect_contact_path(@aspect2.id, alice.guid),
          params: {access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end
    end
  end

  def aspects_membership_service(user=auth.user)
    AspectsMembershipService.new(user)
  end

  # rubocop:disable Metrics/AbcSize
  def confirm_person_format(post_person, user)
    expect(post_person["guid"]).to eq(user.guid)
    expect(post_person["diaspora_id"]).to eq(user.diaspora_handle)
    expect(post_person["name"]).to eq(user.name)
    expect(post_person["avatar"]).to eq(user.profile.image_url)
  end
  # rubocop:enable Metrics/AbcSize
end
