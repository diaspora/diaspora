# frozen_string_literal: true

require_relative "api_spec_helper"

describe Api::V1::PostsController do
  let(:auth) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify private:read private:modify],
      user:   FactoryGirl.create(:user, profile: FactoryGirl.create(:profile_with_image_url))
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

  let(:auth_minimum_scopes) { FactoryGirl.create(:auth_with_default_scopes) }
  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_public_only) { auth_public_only.create_access_token.to_s }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }
  let!(:access_token_public_only_read_only) { auth_public_only_read_only.create_access_token.to_s }
  let!(:access_token_minimum_scopes) { auth_minimum_scopes.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  before do
    alice.person.profile = FactoryGirl.create(:profile_with_image_url)
    bob.person.profile = FactoryGirl.create(:profile_with_image_url)
    eve.person.profile = FactoryGirl.create(:profile_with_image_url)

    @alice_aspect = alice.aspects.first
    @alice_photo1 = alice.post(:photo, pending: true, user_file: File.open(photo_fixture_name), to: @alice_aspect.id)
    @alice_photo2 = alice.post(:photo, pending: true, user_file: File.open(photo_fixture_name), to: @alice_aspect.id)
    @alice_photo_ids = [@alice_photo1.id.to_s, @alice_photo2.id.to_s]
    @alice_photo_guids = [@alice_photo1.guid, @alice_photo2.guid]
  end

  describe "#show" do
    before do
      @status = alice.post(
        :status_message,
        text:   "hello @{#{bob.diaspora_handle}} and @{#{eve.diaspora_handle}}from Alice!",
        public: true,
        to:     "all"
      )
    end

    context "access simple by post ID" do
      it "gets post" do
        get(
          api_v1_post_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(200)
        post = response_body(response)
        confirm_post_format(post, alice, @status, [bob, eve])

        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end
    end

    context "access full post by post ID" do
      it "gets post" do
        base_params = {status_message: {text: "myText #nsfw"}, public: true}
        poll_params = {poll_question: "something?", poll_answers: %w[yes no maybe]}
        location_params = {location_address: "somewhere", location_coords: "1,2"}
        merged_params = base_params.merge(location_params)
        merged_params = merged_params.merge(poll_params)
        merged_params = merged_params.merge(photos: @alice_photo_ids)
        status_message = StatusMessageCreationService.new(alice).create(merged_params)
        status_message.open_graph_cache = FactoryGirl.create(:open_graph_cache, video_url: "http://example.org")
        status_message.o_embed_cache = FactoryGirl.create(:o_embed_cache)
        status_message.save

        get(
          api_v1_post_path(status_message.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(200)
        post = response_body(response)
        confirm_post_format(post, alice, status_message)

        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end
    end

    context "access interacted with post by ID" do
      it "gets post" do
        auth.user.like!(@status)
        auth.user.reshare!(@status)
        auth.user.reports.create!(item: @status, text: "Meh!")
        @status.reload

        get(
          api_v1_post_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(200)
        post = response_body(response)
        confirm_post_format(post, alice, @status, [bob, eve])
        expect(post["own_interaction_state"]["liked"]).to be true
        expect(post["own_interaction_state"]["reshared"]).to be true
        expect(post["own_interaction_state"]["subscribed"]).to be true
        expect(post["own_interaction_state"]["reported"]).to be true

        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end
    end

    context "access reshare style post by post ID" do
      it "gets post" do
        reshare_post = FactoryGirl.create(:reshare, root: @status, author: bob.person)
        get(
          api_v1_post_path(reshare_post.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(200)
        post = response_body(response)
        confirm_reshare_format(post, @status, alice)

        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end
    end

    context "access private post not to reader" do
      it "fails to get post" do
        private_post = alice.post(:status_message, text: "to aspect only", public: false, to: alice.aspects.first.id)
        get(
          api_v1_post_path(private_post.guid),
          params: {
            access_token: access_token
          }
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "access private post to reader without private:read scope in token" do
      it "fails to get post" do
        alice_shared_aspect = alice.aspects.create(name: "shared aspect")
        alice.share_with(auth_public_only_read_only.user.person, alice_shared_aspect)
        alice.share_with(auth_read_only.user.person, alice_shared_aspect)

        shared_post = alice.post(:status_message, text: "to aspect only", public: false, to: alice_shared_aspect.id)
        get(
          api_v1_post_path(shared_post.guid),
          params: {
            access_token: access_token_public_only_read_only
          }
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")

        get(
          api_v1_post_path(shared_post.guid),
          params: {
            access_token: access_token_read_only
          }
        )
        expect(response.status).to eq(200)
      end
    end

    context "access post with invalid id" do
      it "fails to get post" do
        get(
          api_v1_post_path("999_999_999"),
          params: {
            access_token: access_token
          }
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "access with invalid token" do
      it "fails" do
        get(
          api_v1_post_path(@status.guid),
          params: {
            access_token: invalid_token
          }
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#create" do
    before do
      @user_photo1 = auth.user.post(:photo, pending: true, user_file: File.open(photo_fixture_name), public: true)
      @user_photo2 = auth.user.post(:photo, pending: true, user_file: File.open(photo_fixture_name), public: true)
      @user_photo3 = auth.user.post(:photo, pending: false, user_file: File.open(photo_fixture_name), public: true)
      @user_photo_ids = [@user_photo1.id.to_s, @user_photo2.id.to_s]
      @user_photo_guids = [@user_photo1.guid, @user_photo2.guid]
    end

    context "when given read-write access token" do
      it "creates a public post" do
        post_for_ref_only = auth.user.post(
          :status_message,
          text:   "Hello this is a public post!",
          public: true
        )

        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         "Hello this is a public post!",
            public:       true
          }
        )
        expect(response.status).to eq(200)
        post = response_body(response)
        confirm_post_format(post, auth.user, post_for_ref_only)
        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end

      it "or creates a private post" do
        aspect = auth.user.aspects.create(name: "new aspect")
        post_for_ref_only = auth.user.post(
          :status_message,
          text:       "Hello this is a private post!",
          aspect_ids: [aspect.id]
        )

        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         "Hello this is a private post!",
            public:       false,
            aspects:      [aspect.id]
          }
        )
        post = response_body(response)
        expect(response.status).to eq(200)
        confirm_post_format(post, auth.user, post_for_ref_only)
        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end

      it "doesn't creates a private post without private:modify scope in token" do
        aspect = auth.user.aspects.create(name: "new aspect")
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token_public_only,
            body:         "Hello this is a private post!",
            public:       false,
            aspects:      [aspect.id]
          }
        )

        confirm_api_error(response, 422, "Failed to create the post")
      end
    end

    context "with fully populated post" do
      it "creates with photos" do
        message_text = "Post with photos"

        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true,
            photos:       @user_photo_guids
          }
        )
        expect(response.status).to eq(200)
        post = response_body(response)

        @user_photo1[:pending] = true
        @user_photo1.save
        @user_photo2[:pending] = true
        @user_photo2.save
        base_params = {status_message: {text: message_text}, public: true}
        merged_params = base_params.merge(photos: @user_photo_ids)
        post_for_ref_only = StatusMessageCreationService.new(auth.user).create(merged_params)

        confirm_post_format(post, auth.user, post_for_ref_only)
        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end

      it "fails to add other's photos" do
        message_text = "Post with photos"

        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true,
            photos:       @alice_photo_guids
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails to add non-pending photos" do
        message_text = "Post with photos"

        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true,
            photos:       [@user_photo3.guid]
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails to add bad photo guids" do
        message_text = "Post with photos"

        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true,
            photos:       ["999_999_999"]
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "creates with poll" do
        message_text = "status with a poll"
        poll_params = {poll_question: "something?", poll_answers: %w[yes no maybe]}
        base_params = {status_message: {text: message_text}, public: true}
        merged_params = base_params.merge(poll_params)
        post_for_ref_only = StatusMessageCreationService.new(auth.user).create(merged_params)

        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true,
            poll:         {
              question:     "something?",
              poll_answers: %w[yes no maybe]
            }
          }
        )
        post = response_body(response)
        expect(response.status).to eq(200)
        confirm_post_format(post, auth.user, post_for_ref_only)
        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end

      it "fails poll with no answers" do
        message_text = "status with a poll"
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true,
            poll:         {
              question:     "something?",
              poll_answers: []
            }
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails poll with blank answer" do
        message_text = "status with a poll"
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true,
            poll:         {
              question:     "question",
              poll_answers: ["yes", ""]
            }
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails poll with blank question and message text" do
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         "",
            public:       true,
            poll:         {
              question:     "question",
              poll_answers: %w[yes no]
            }
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "creates with location" do
        message_text = "status with location"
        base_params = {status_message: {text: message_text}, public: true}
        location_params = {location_address: "somewhere", location_coords: "1,2"}
        merged_params = base_params.merge(location_params)
        post_for_ref_only = StatusMessageCreationService.new(auth.user).create(merged_params)

        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true,
            location:     {
              address: "somewhere",
              lat:     1,
              lng:     2
            }
          }
        )
        post = response_body(response)
        expect(response.status).to eq(200)
        confirm_post_format(post, auth.user, post_for_ref_only)
        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end

      it "creates with mentions" do
        message_text = "hello @{#{alice.diaspora_handle}} from Bob!"
        post_for_ref_only = auth.user.post(
          :status_message,
          text:   message_text,
          public: true
        )

        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true
          }
        )
        post = response_body(response)
        expect(response.status).to eq(200)
        confirm_post_format(post, auth.user, post_for_ref_only, [alice])
      end
    end

    context "when given NSFW hashtag" do
      it "creates NSFW post" do
        message_text = "hello @{#{alice.diaspora_handle}} from Bob but this is #nsfw!"
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       true
          }
        )
        expect(response.status).to eq(200)
        post = response_body(response)
        expect(post["nsfw"]).to be_truthy
        expect(post.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end
    end

    context "when given just photos" do
      it "creates the post" do
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            public:       true,
            photos:       @user_photo_guids
          }
        )
        expect(response.status).to eq(200)
        expect(response.body).to match_json_schema(:api_v1_schema, fragment: "#/definitions/post")
      end

      it "fails to add other's photos" do
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            public:       true,
            photos:       @alice_photo_guids
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails to add non-pending photos" do
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            public:       true,
            photos:       [@user_photo3.guid]
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails to add bad photo guids" do
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            public:       true,
            photos:       ["999_999_999"]
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end
    end

    context "when given bad post" do
      it "fails when no body" do
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            public:       true
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails when no public field and no aspects" do
        message_text = "hello @{#{alice.diaspora_handle}} from Bob!"
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails when private no aspects" do
        message_text = "hello @{#{alice.diaspora_handle}} from Bob!"
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       false
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails when unknown aspect IDs" do
        message_text = "hello @{#{alice.diaspora_handle}} from Bob!"
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            public:       false,
            aspects:      ["-1"]
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end

      it "fails when no public field but aspects" do
        aspect = auth.user.aspects.create(name: "new aspect")
        auth.user.share_with(alice.person, aspect)
        message_text = "hello @{#{alice.diaspora_handle}} from Bob!"
        post(
          api_v1_posts_path,
          params: {
            access_token: access_token,
            body:         message_text,
            aspects:      [aspect.id]
          }
        )
        confirm_api_error(response, 422, "Failed to create the post")
      end
    end

    context "improper credentials" do
      it "fails without modify token" do
        post(
          api_v1_posts_path,
          params: {
            access_token:   access_token_read_only,
            status_message: {text: "Hello this is a post!"},
            public:         true
          }
        )
        expect(response.status).to eq(403)
      end

      it "fails without invalid token" do
        post(
          api_v1_posts_path,
          params: {
            access_token:   invalid_token,
            status_message: {text: "Hello this is a post!"},
            public:         true
          }
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#destroy" do
    context "when given read-write access token" do
      it "attempts to destroy the post" do
        @status = auth.user.post(
          :status_message,
          text:   "hello",
          public: true,
          to:     "all"
        )
        delete(
          api_v1_post_path(@status.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)
      end
    end

    context "when given read only access token" do
      it "doesn't delete the post" do
        @status = auth.user.post(
          :status_message,
          text:   "hello",
          public: true
        )
        delete(
          api_v1_post_path(@status.guid),
          params: {access_token: access_token_read_only}
        )

        expect(response.status).to eq(403)
      end
    end

    context "when given invalid token" do
      it "doesn't delete the post" do
        @status = auth.user.post(
          :status_message,
          text:   "hello",
          public: true
        )
        delete(
          api_v1_post_path(@status.guid),
          params: {access_token: invalid_token}
        )

        expect(response.status).to eq(401)
      end
    end

    context "when post is private but no private:modify scope in token" do
      it "doesn't delete the post" do
        aspect = auth_public_only.user.aspects.create(name: "new aspect")
        @status = auth_public_only.user.post(
          :status_message,
          text:    "hello",
          aspects: [aspect.id]
        )
        delete(
          api_v1_post_path(@status.guid),
          params: {access_token: access_token_public_only}
        )

        expect(response.status).to eq(403)
      end
    end

    context "when given invalid Post ID" do
      it "doesn't delete a post" do
        delete(
          api_v1_post_path("999_999_999"),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Post with provided guid could not be found")
      end
    end

    context "when PostID refers to another user's post" do
      it "fails to delete post" do
        status = alice.post(
          :status_message,
          text:   "hello",
          public: true,
          to:     "all"
        )

        delete(
          api_v1_post_path(status.guid),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 403, "Not allowed to delete the post")
      end
    end
  end

  def response_body(response)
    JSON.parse(response.body)
  end

  private

  # rubocop:disable Metrics/AbcSize
  def confirm_post_format(post, user, reference_post, mentions=[])
    confirm_post_top_level(post, reference_post)
    confirm_person_format(post["author"], user)
    confirm_interactions(post["interaction_counters"], reference_post)
    confirm_own_interaction_state(post["own_interaction_state"], reference_post)

    mentions.each do |mention|
      post_mentions = post["mentioned_people"]
      post_mention = post_mentions.find {|m| m["guid"] == mention.guid }
      confirm_person_format(post_mention, mention)
    end

    confirm_poll(post["poll"], reference_post.poll, false) if reference_post.poll
    confirm_location(post["location"], reference_post.location) if reference_post.location
    confirm_photos(post["photos"], reference_post.photos) if reference_post.photos
    confirm_open_graph_object(post["open_graph_object"], reference_post.open_graph_cache)
    confirm_oembed(post["oembed"], reference_post.o_embed_cache)
  end

  def confirm_post_top_level(post, reference_post)
    expect(post.has_key?("guid")).to be_truthy
    expect(post.has_key?("created_at")).to be_truthy
    expect(post["created_at"]).not_to be_nil
    expect(post["title"]).to eq(reference_post.message.title)
    expect(post["body"]).to eq(reference_post.message.plain_text_for_json)
    expect(post["post_type"]).to eq(reference_post.post_type)
    expect(post["provider_display_name"]).to eq(reference_post.provider_display_name)
    expect(post["public"]).to eq(reference_post.public)
    expect(post["nsfw"]).to eq(!!reference_post.nsfw) # rubocop:disable Style/DoubleNegation
  end

  def confirm_interactions(interactions, reference_post)
    expect(interactions["comments"]).to eq(reference_post.comments_count)
    expect(interactions["likes"]).to eq(reference_post.likes_count)
    expect(interactions["reshares"]).to eq(reference_post.reshares_count)
  end

  def confirm_own_interaction_state(state, reference_post)
    expect(state["liked"]).to eq(reference_post.likes.where(author: auth.user.person).exists?)
    expect(state["reshared"]).to eq(reference_post.reshares.where(author: auth.user.person).exists?)
    expect(state["subscribed"]).to eq(reference_post.participations.where(author: auth.user.person).exists?)
    expect(state["reported"]).to eq(reference_post.reports.where(user: auth.user).exists?)
  end

  def confirm_person_format(post_person, user)
    expect(post_person["guid"]).to eq(user.guid)
    expect(post_person["diaspora_id"]).to eq(user.diaspora_handle)
    expect(post_person["name"]).to eq(user.name)
    expect(post_person["avatar"]).to eq(user.profile.image_url(size: :thumb_medium))
  end

  def confirm_poll(post_poll, ref_poll, expected_participation)
    return unless ref_poll

    expect(post_poll.has_key?("guid")).to be_truthy
    expect(post_poll["participation_count"]).to eq(ref_poll.participation_count)
    expect(post_poll["already_participated"]).to eq(expected_participation)
    expect(post_poll["question"]).to eq(ref_poll.question)

    answers = post_poll["poll_answers"]
    answers.each do |answer|
      actual_answer = ref_poll.poll_answers.find {|a| a[:answer] == answer["answer"] }
      expect(answer["answer"]).to eq(actual_answer[:answer])
      expect(answer["vote_count"]).to eq(actual_answer[:vote_count])
    end
  end

  def confirm_location(location, ref_location)
    expect(location["address"]).to eq(ref_location[:address])
    expect(location["lat"]).to eq(ref_location[:lat].to_f)
    expect(location["lng"]).to eq(ref_location[:lng].to_f)
  end

  def confirm_photos(photos, ref_photos)
    expect(photos.size).to eq(ref_photos.size)
    photos.each do |photo|
      expect(photo["dimensions"].has_key?("height")).to be_truthy
      expect(photo["dimensions"].has_key?("height")).to be_truthy
      expect(photo["sizes"]["small"]).to be_truthy
      expect(photo["sizes"]["medium"]).to be_truthy
      expect(photo["sizes"]["large"]).to be_truthy
    end
  end

  def confirm_open_graph_object(object, ref_cache)
    return unless ref_cache

    expect(object["type"]).to eq(ref_cache.ob_type)
    expect(object["url"]).to eq(ref_cache.url)
    expect(object["title"]).to eq(ref_cache.title)
    expect(object["image"]).to eq(ref_cache.image)
    expect(object["description"]).to eq(ref_cache.description)
    expect(object["video_url"]).to eq(ref_cache.video_url)
  end

  def confirm_oembed(response, ref_cache)
    return unless ref_cache

    expect(response).to eq(ref_cache.data)
    expect(response["trusted_endpoint_url"]).to_not be_nil
  end

  def confirm_reshare_format(post, root_post, root_poster)
    root = post["root"]
    expect(root.has_key?("guid")).to be_truthy
    expect(root["guid"]).to eq(root_post[:guid])
    expect(root.has_key?("created_at")).to be_truthy
    confirm_person_format(root["author"], root_poster)
  end
  # rubocop:enable Metrics/AbcSize
end
