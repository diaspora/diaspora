# frozen_sTring_literal: true

require "spec_helper"

describe Api::V1::UsersController do
  include PeopleHelper

  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let(:auth_read_only) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }

  describe "#show" do
    context "Current User" do
      it "succeeds when logged in" do
        get(
          api_v1_user_path,
          params: {access_token: access_token}
        )
        user = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(user["guid"]).to eq(auth.user.guid)
        confirm_self_data_format(user)
      end

      it "fails if invalid token" do
        get(
          api_v1_user_path,
          params: {access_token: "999_999_999"}
        )
        expect(response.status).to eq(401)
      end
    end

    context "Single User" do
      it "succeeds with public user not in Aspect" do
        alice.profile[:public_details] = true
        alice.profile.save
        get(
          "/api/v1/users/#{alice.guid}",
          params: {access_token: access_token}
        )
        user = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(user["guid"]).to eq(alice.person.guid)
        confirm_public_profile_hash(user)
      end

      it "succeeds with in Aspect valid user" do
        alice.profile[:public_details] = true
        alice.profile.save
        auth.user.share_with(alice.person, auth.user.aspects.first)
        get(
          "/api/v1/users/#{alice.guid}",
          params: {access_token: access_token}
        )
        user = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(user["guid"]).to eq(alice.person.guid)
        confirm_public_profile_hash(user)
      end

      it "succeeds with limited data on non-public/not shared" do
        eve.profile[:public_details] = false
        eve.profile.save
        get(
          "/api/v1/users/#{eve.guid}",
          params: {access_token: access_token}
        )
        user = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(user["guid"]).to eq(eve.person.guid)
        confirm_private_profile_hash(user)

        eve.aspects.create(name: "new aspect")
        eve.share_with(auth.user.person, eve.aspects.first)
        get(
          "/api/v1/users/#{eve.guid}",
          params: {access_token: access_token}
        )
        user = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(user["guid"]).to eq(eve.person.guid)
        confirm_public_profile_hash(user)
      end

      it "fails if invalid token" do
        get(
          api_v1_user_path(alice.person.guid),
          params: {access_token: "999_999_999"}
        )
        expect(response.status).to eq(401)
      end

      it "fails with invalid user GUID" do
        get(
          "/api/v1/users/999_999_999",
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.users.not_found"))
      end
    end
  end

  describe "#update" do
    context "Partial with all valid fields" do
      it "succeeds when logged in" do
        new_location = "New Location"
        new_bio = "New Bio"
        patch(
          api_v1_user_path,
          params: {location: new_location, bio: new_bio, access_token: access_token}
        )
        expect(response.status).to eq(200)
        user = JSON.parse(response.body)
        confirm_self_data_format(user)
        expect(user["bio"]).to eq(new_bio)
        expect(user["location"]).to eq(new_location)
        auth.user.profile.reload
        expect(auth.user.profile[:location]).to eq(new_location)
        expect(auth.user.profile[:bio]).to eq(new_bio)
      end
    end

    context "Full with all valid fields" do
      it "succeeds" do
        new_bio = "new bio"
        new_birthday = Time.current + 8_640_000
        new_gender = "ask1"
        new_location = "new location"
        new_first_name = "new first"
        new_last_name = "new last"
        new_searchable = !auth.user.profile[:searchable]
        new_show_profile_info = !auth.user.profile[:public_details]
        new_nsfw = !auth.user.profile[:nsfw]
        new_tags = %w[tag1 tag2]
        patch(
          api_v1_user_path,
          params: {
            bio:               new_bio,
            location:          new_location,
            gender:            new_gender,
            birthday:          new_birthday,
            first_name:        new_first_name,
            last_name:         new_last_name,
            searchable:        new_searchable,
            show_profile_info: new_show_profile_info,
            nsfw:              new_nsfw,
            tags:              new_tags,
            access_token:      access_token
          }
        )
        expect(response.status).to eq(200)
        user = JSON.parse(response.body)
        confirm_self_data_format(user)
        expect(user["bio"]).to eq(new_bio)
        expect(user["birthday"]).to eq(birthday_format(new_birthday))
        expect(user["location"]).to eq(new_location)
        expect(user["gender"]).to eq(new_gender)
        expect(user["first_name"]).to eq(new_first_name)
        expect(user["last_name"]).to eq(new_last_name)
        expect(user["searchable"]).to eq(new_searchable)
        expect(user["show_profile_info"]).to eq(new_show_profile_info)
        expect(user["nsfw"]).to eq(new_nsfw)
        expect(user["tags"]).to eq(new_tags)
        auth.user.profile.reload
        expect(auth.user.profile[:location]).to eq(new_location)
        expect(auth.user.profile[:bio]).to eq(new_bio)
        expect(birthday_format(auth.user.profile[:birthday])).to eq(birthday_format(new_birthday))
        expect(auth.user.profile[:gender]).to eq(new_gender)
        expect(auth.user.profile[:first_name]).to eq(new_first_name)
        expect(auth.user.profile[:last_name]).to eq(new_last_name)
        expect(auth.user.profile[:searchable]).to eq(new_searchable)
        expect(auth.user.profile[:public_details]).to eq(new_show_profile_info)
        expect(auth.user.profile[:nsfw]).to eq(new_nsfw)
        expect(user["tags"]).to eq(new_tags)
      end
    end

    context "fails" do
      it "skips invalid fields" do
        new_bio = "new bio"
        patch(
          api_v1_user_path,
          params: {
            bio:                        new_bio,
            no_idea_what_field_this_is: "some value",
            access_token:               access_token
          }
        )
        expect(response.status).to eq(200)
        user = JSON.parse(response.body)
        expect(user["bio"]).to eq(new_bio)
        expect(user.has_key?("no_idea_what_field_this_is")).to be_falsey
      end

      it "fails to update guid" do
        new_bio = "new bio"
        original_guid = auth.user.guid.to_s
        patch(
          api_v1_user_path,
          params: {
            bio:          new_bio,
            guid:         "999_999_999",
            access_token: access_token
          }
        )
        expect(response.status).to eq(200)
        user = JSON.parse(response.body)
        expect(user["bio"]).to eq(new_bio)
        expect(user["guid"]).to eq(original_guid)
      end

      it "fails if invalid token" do
        patch(
          api_v1_user_path,
          params: {location: "New Location", bio: "New Bio", access_token: "999_999_999"}
        )
        expect(response.status).to eq(401)
      end

      it "fails if read only token" do
        patch(
          api_v1_user_path,
          params: {location: "New Location", bio: "New Bio", access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#contacts" do
    it "succeeds when logged in and ask for own" do
      get(
        api_v1_user_contacts_path(auth.user.guid),
        params: {access_token: access_token}
      )
      expect(response.status).to eq(200)
      contacts = response_body_data(response)
      expect(contacts.length).to eq(0)

      auth.user.share_with(alice.person, auth.user.aspects.first)
      get(
        api_v1_user_contacts_path(auth.user.guid),
        params: {access_token: access_token}
      )
      expect(response.status).to eq(200)
      contacts = response_body_data(response)
      expect(contacts.length).to eq(1)
      confirm_person_format(contacts[0], alice)
    end

    it "fails with invalid GUID" do
      get(
        api_v1_user_contacts_path("999_999_999"),
        params: {access_token: access_token}
      )
      expect(response.status).to eq(404)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.users.not_found"))
    end

    it "fails with other user's GUID" do
      get(
        api_v1_user_contacts_path(alice.guid),
        params: {access_token: access_token}
      )
      expect(response.status).to eq(404)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.users.not_found"))
    end

    it "fails if invalid token" do
      get(
        api_v1_user_contacts_path(alice.guid),
        params: {access_token: "999_999_999"}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "#photos" do
    before do
      alice_private_spec = alice.aspects.create(name: "private aspect")
      alice.share_with(eve.person, alice_private_spec)
      alice.share_with(auth.user.person, alice.aspects.first)

      auth.user.post(:photo, pending: false, user_file: File.open(photo_fixture_name), to: "all")
      auth.user.post(:photo, pending: false, user_file: File.open(photo_fixture_name), to: "all")
      @public_photo1 = alice.post(:photo, pending: false, user_file: File.open(photo_fixture_name), to: "all")
      @public_photo2 = alice.post(:photo, pending: false, user_file: File.open(photo_fixture_name), to: "all")
      @shared_photo1 = alice.post(:photo, pending: false, user_file: File.open(photo_fixture_name),
                                  to: alice.aspects.first.id)
      @private_photo1 = alice.post(:photo, pending: false, user_file: File.open(photo_fixture_name),
                                   to: alice_private_spec.id)
    end

    context "logged in" do
      it "returns only visible photos of other user" do
        get(
          api_v1_user_photos_path(alice.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        photos = response_body_data(response)
        expect(photos.length).to eq(3)
        guids = photos.map {|photo| photo["guid"] }
        expect(guids).to include(@public_photo1.guid, @public_photo2.guid, @shared_photo1.guid)
        expect(guids).not_to include(@private_photo1.guid)
        confirm_photos(photos)
      end

      it "returns logged in user's photos" do
        get(
          api_v1_user_photos_path(auth.user.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        photos = JSON.parse(response.body)
        expect(photos.length).to eq(2)
      end
    end

    it "fails with invalid GUID" do
      get(
        api_v1_user_photos_path("999_999_999"),
        params: {access_token: access_token}
      )
      expect(response.status).to eq(404)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.users.not_found"))
    end

    it "fails if invalid token" do
      get(
        api_v1_user_photos_path(alice.guid),
        params: {access_token: "999_999_999"}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "#posts" do
    before do
      alice_private_spec = alice.aspects.create(name: "private aspect")
      alice.share_with(eve.person, alice_private_spec)
      alice.share_with(auth.user.person, alice.aspects.first)

      auth.user.post(:status_message, text: "auth user message1", public: true, to: "all")
      auth.user.post(:status_message, text: "auth user message2", public: true, to: "all")
      @public_post1 = alice.post(:status_message, text: "alice public message1", public: true, to: "all")
      @public_post2 = alice.post(:status_message, text: "alice public message2", public: true, to: "all")
      @shared_post1 = alice.post(:status_message, text: "alice limited to auth user message",
                                 public: false, to: alice.aspects.first.id)
      @private_post1 = alice.post(:status_message, text: "alice limited hidden from auth user message",
                                  public: false, to: alice_private_spec.id)
    end

    context "logged in" do
      it "returns only visible posts of other user" do
        get(
          api_v1_user_posts_path(alice.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        posts = response_body_data(response)
        expect(posts.length).to eq(3)
        guids = posts.map {|post| post["guid"] }
        expect(guids).to include(@public_post1.guid, @public_post2.guid, @shared_post1.guid)
        expect(guids).not_to include(@private_post1.guid)
        post = posts.select {|p| p["guid"] == @public_post1.guid }
        confirm_post_format(post[0], alice, @public_post1)
      end

      it "returns logged in user's posts" do
        get(
          api_v1_user_posts_path(auth.user.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        posts = response_body_data(response)
        expect(posts.length).to eq(2)
      end
    end

    it "fails with invalid GUID" do
      get(
        api_v1_user_posts_path("999_999_999"),
        params: {access_token: access_token}
      )
      expect(response.status).to eq(404)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.users.not_found"))
    end

    it "fails if invalid token" do
      get(
        api_v1_user_posts_path(alice.person.guid),
        params: {access_token: "999_999_999"}
      )
      expect(response.status).to eq(401)
    end
  end

  def confirm_self_data_format(json)
    confirm_common_profile_elements(json)
    confirm_profile_details(json)
    expect(json).to have_key("searchable")
    expect(json).to have_key("show_profile_info")
  end

  def confirm_public_profile_hash(json)
    confirm_common_profile_elements(json)
    confirm_profile_details(json)
    expect(json).to have_key("blocked")
    expect(json).to have_key("relationship")
    expect(json).to have_key("aspects")
  end

  # rubocop:disable Metrics/AbcSize
  def confirm_private_profile_hash(json)
    confirm_common_profile_elements(json)
    expect(json).to have_key("blocked")
    expect(json).to have_key("relationship")
    expect(json).to have_key("aspects")
    expect(json).not_to have_key("birthday")
    expect(json).not_to have_key("gender")
    expect(json).not_to have_key("location")
    expect(json).not_to have_key("bio")
  end

  def confirm_common_profile_elements(json)
    expect(json).to have_key("guid")
    expect(json).to have_key("diaspora_id")
    expect(json).to have_key("first_name")
    expect(json).to have_key("last_name")
    expect(json).to have_key("avatar")
    expect(json).to have_key("tags")
  end

  def confirm_profile_details(json)
    expect(json).to have_key("birthday")
    expect(json).to have_key("gender")
    expect(json).to have_key("location")
    expect(json).to have_key("bio")
  end

  def confirm_post_format(post, user, reference_post)
    confirm_post_top_level(post, reference_post)
    confirm_person_format(post["author"], user)
    confirm_interactions(post["interaction_counters"], reference_post)
  end

  def confirm_post_top_level(post, reference_post)
    expect(post["guid"]).to eq(reference_post.guid)
    expect(post.has_key?("created_at")).to be_truthy
    expect(post["created_at"]).not_to be_nil
    expect(post["title"]).to eq(reference_post.message.title)
    expect(post["body"]).to eq(reference_post.message.plain_text_for_json)
    expect(post["post_type"]).to eq(reference_post.post_type)
    expect(post["provider_display_name"]).to eq(reference_post.provider_display_name)
    expect(post["public"]).to eq(reference_post.public)
    expect(post["nsfw"]).to eq(reference_post.nsfw)
  end

  def confirm_interactions(interactions, reference_post)
    expect(interactions["comments"]).to eq(reference_post.comments_count)
    expect(interactions["likes"]).to eq(reference_post.likes_count)
    expect(interactions["reshares"]).to eq(reference_post.reshares_count)
  end

  def confirm_person_format(post_person, user)
    expect(post_person["guid"]).to eq(user.guid)
    expect(post_person["diaspora_id"]).to eq(user.diaspora_handle)
    expect(post_person["name"]).to eq(user.name)
    expect(post_person["avatar"]).to eq(user.profile.image_url)
  end

  def confirm_photos(photos)
    photos.each do |photo|
      expect(photo.has_key?("guid")).to be_truthy
      expect(photo["dimensions"].has_key?("height")).to be_truthy
      expect(photo["sizes"]["small"]).to be_truthy
      expect(photo["sizes"]["medium"]).to be_truthy
      expect(photo["sizes"]["large"]).to be_truthy
    end
  end
  # rubocop:enable Metrics/AbcSize

  def response_body_data(response)
    JSON.parse(response.body)["data"]
  end
end
