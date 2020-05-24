# frozen_sTring_literal: true

require_relative "api_spec_helper"

describe Api::V1::PhotosController do
  let(:auth) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify private:read private:modify]
    )
  }

  let(:auth_public_only) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify]
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

  let(:auth_minimum_scopes) {
    FactoryGirl.create(:auth_with_default_scopes)
  }

  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_public_only) { auth_public_only.create_access_token.to_s }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }
  let!(:access_token_public_only_read_only) { auth_public_only_read_only.create_access_token.to_s }
  let!(:access_token_minimum_scopes) { auth_minimum_scopes.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  before do
    alice_private_spec = alice.aspects.create(name: "private aspect")
    alice.share_with(eve.person, alice_private_spec)
    @private_photo1 = alice.post(:photo, pending: false, user_file: File.open(photo_fixture_name),
                                to: alice_private_spec.id)
    @alice_public_photo = alice.post(:photo, pending: false, user_file: File.open(photo_fixture_name), public: true)
    @user_photo1 = auth.user.post(:photo, pending: true, user_file: File.open(photo_fixture_name), to: "all")
    @user_photo2 = auth.user.post(:photo, pending: true, user_file: File.open(photo_fixture_name), to: "all")
    message_data = {status_message: {text: "Post with photos"}, public: true, photos: [@user_photo2.id.to_s]}
    @status_message = StatusMessageCreationService.new(auth.user).create(message_data)
    @user_photo2.reload

    shared_spec = auth_public_only_read_only.user.aspects.create(name: "shared aspect")
    auth_public_only_read_only.user.share_with(auth_public_only_read_only.user.person, shared_spec)
    auth_public_only_read_only.user.share_with(auth_read_only.user.person, shared_spec)

    @shared_photo1 = auth_public_only_read_only.user.post(
      :photo,
      pending:   false,
      user_file: File.open(photo_fixture_name),
      to:        shared_spec.id
    )
  end

  describe "#show" do
    context "succeeds" do
      it "with correct GUID user's photo and access token" do
        get(
          api_v1_photo_path(@user_photo1.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        photo = response_body(response)
        expect(photo.has_key?("post")).to be_falsey
        confirm_photo_format(photo, @user_photo1)

        expect(photo.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/photo")
      end

      it "with correct GUID user's photo used in post and access token" do
        get(
          api_v1_photo_path(@user_photo2.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        photo = response_body(response)
        expect(photo.has_key?("post")).to be_truthy
        confirm_photo_format(photo, @user_photo2)
      end

      it "with correct GUID of other user's public photo and access token" do
        get(
          api_v1_photo_path(@alice_public_photo.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        photo = response_body(response)
        confirm_photo_format(photo, @alice_public_photo)
      end
    end

    context "fails" do
      it "with other this user's private photo without private:read scope in token" do
        get(
          api_v1_photo_path(@shared_photo1.guid),
          params: {access_token: access_token_public_only_read_only}
        )
        confirm_api_error(response, 404, "Photo with provided guid could not be found")
      end

      it "with other user's private photo" do
        get(
          api_v1_photo_path(@private_photo1.guid),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Photo with provided guid could not be found")
      end

      it "with invalid GUID" do
        get(
          api_v1_photo_path("999_999_999"),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Photo with provided guid could not be found")
      end

      it "with invalid access token" do
        delete(
          api_v1_photo_path(@user_photo1.guid),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#index" do
    context "succeeds" do
      it "with correct access token" do
        get(
          api_v1_photos_path,
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        photos = response_body_data(response)
        expect(photos.length).to eq(2)

        expect(photos.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/photos")
      end
    end

    context "only lists public photos" do
      before do
        auth_public_only_read_only.user.post(:photo, pending: false, user_file: File.open(photo_fixture_name),
                                                 public: true)
      end

      it "with correct only public scope token" do
        get(
          api_v1_photos_path,
          params: {access_token: access_token_public_only_read_only}
        )
        expect(response.status).to eq(200)
        photos = response_body_data(response)
        expect(photos.length).to eq(1)
      end
    end

    context "fails" do
      it "with invalid access token" do
        delete(
          api_v1_photos_path,
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#create" do
    before do
      @encoded_photo = Rack::Test::UploadedFile.new(
        Rails.root.join("spec", "fixtures", "button.png").to_s,
        "image/png"
      )
    end

    context "succeeds" do
      it "with valid encoded file no arguments" do
        post(
          api_v1_photos_path,
          params: {image: @encoded_photo, access_token: access_token}
        )
        expect(response.status).to eq(200)
        photo = response_body(response)
        ref_photo = auth.user.photos.reload.find_by(guid: photo["guid"])
        expect(ref_photo.pending).to be_falsey
        confirm_photo_format(photo, ref_photo)
      end

      it "with valid encoded file set as pending" do
        post(
          api_v1_photos_path,
          params: {image: @encoded_photo, pending: false, access_token: access_token}
        )
        expect(response.status).to eq(200)
        photo = response_body(response)
        expect(photo.has_key?("post")).to be_falsey
        ref_photo = auth.user.photos.reload.find_by(guid: photo["guid"])
        expect(ref_photo.pending).to be_falsey
        confirm_photo_format(photo, ref_photo)

        post(
          api_v1_photos_path,
          params: {image: @encoded_photo, pending: true, access_token: access_token}
        )
        expect(response.status).to eq(200)
        photo = response_body(response)
        ref_photo = auth.user.photos.reload.find_by(guid: photo["guid"])
        expect(ref_photo.pending).to be_truthy
      end

      it "with valid encoded file as profile photo" do
        post(
          api_v1_photos_path,
          params: {image: @encoded_photo, set_profile_photo: true, access_token: access_token}
        )
        expect(response.status).to eq(200)
        photo = response_body(response)
        expect(auth.user.reload.person.profile.image_url_small).to eq(photo["sizes"]["small"])
      end
    end

    context "fails" do
      it "with no image" do
        post(
          api_v1_photos_path,
          params: {access_token: access_token}
        )
        confirm_api_error(response, 422, "Failed to create the photo")
      end

      it "with non-image file" do
        text_file = Rack::Test::UploadedFile.new(
          Rails.root.join("README.md").to_s,
          "text/plain"
        )
        post(
          api_v1_photos_path,
          params: {image: text_file, access_token: access_token}
        )
        confirm_api_error(response, 422, "Failed to create the photo")
      end

      it "with impromperly identified file" do
        text_file = Rack::Test::UploadedFile.new(
          Rails.root.join("README.md").to_s,
          "image/png"
        )
        post(
          api_v1_photos_path,
          params: {image: text_file, access_token: access_token}
        )
        confirm_api_error(response, 422, "Failed to create the photo")
      end

      it "with invalid access token" do
        post(
          api_v1_photos_path,
          params: {image: @encoded_photo, access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end

      it "with read only access token" do
        post(
          api_v1_photos_path,
          params: {image: @encoded_photo, access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end

      it "with private photo and no private:modify access token" do
        post(
          api_v1_photos_path,
          params: {image: @encoded_photo, access_token: access_token_public_only_read_only}
        )
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#destroy" do
    context "succeeds" do
      it "with correct GUID and access token" do
        expect(auth.user.photos.find_by(id: @user_photo1.id)).to eq(@user_photo1)
        delete(
          api_v1_photo_path(@user_photo1.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)
        expect(auth.user.photos.find_by(id: @user_photo1.id)).to be_nil
      end
    end

    context "fails" do
      it "with other user's photo GUID and access token" do
        delete(
          api_v1_photo_path(@alice_public_photo.guid),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Photo with provided guid could not be found")
      end

      it "with other invalid GUID" do
        delete(
          api_v1_photo_path("999_999_999"),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Photo with provided guid could not be found")
      end

      it "with invalid access token" do
        delete(
          api_v1_photo_path(@user_photo1.guid),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end

      it "with read only access token" do
        delete(
          api_v1_photo_path(@user_photo1.guid),
          params: {access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end

      it "with private photo and no private:modify token" do
        delete(
          api_v1_photo_path(@shared_photo1.guid),
          params: {access_token: access_token_public_only_read_only}
        )
        expect(response.status).to eq(403)
      end
    end
  end

  def response_body(response)
    JSON.parse(response.body)
  end

  def response_body_data(response)
    response_body(response)
  end

  # rubocop:disable Metrics/AbcSize
  def confirm_photo_format(photo, ref_photo)
    expect(photo["guid"]).to eq(ref_photo.guid)
    if ref_photo.status_message_guid
      expect(photo["post"]).to eq(ref_photo.status_message_guid)
    else
      expect(photo.has_key?("post")).to be_falsey
    end
    expect(photo["dimensions"].has_key?("height")).to be_truthy
    expect(photo["dimensions"].has_key?("width")).to be_truthy
    expect(photo["sizes"]["small"]).to be_truthy
    expect(photo["sizes"]["medium"]).to be_truthy
    expect(photo["sizes"]["large"]).to be_truthy
  end
  # rubocop:enable Metrics/AbcSize
end
