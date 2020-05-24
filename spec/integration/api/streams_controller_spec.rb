# frozen_string_literal: true

require_relative "api_spec_helper"

describe Api::V1::StreamsController do
  let(:auth_read_only) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read private:read contacts:read tags:read],
      user:   FactoryGirl.create(:user, profile: FactoryGirl.create(:profile_with_image_url))
    )
  }

  let(:auth_public_only_tags) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read tags:read],
      user:   FactoryGirl.create(:user, profile: FactoryGirl.create(:profile_with_image_url))
    )
  }

  let(:auth_public_only_read_only) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read],
      user:   FactoryGirl.create(:user, profile: FactoryGirl.create(:profile_with_image_url))
    )
  }

  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }
  let!(:access_token_public_only_tags) { auth_public_only_tags.create_access_token.to_s }
  let!(:access_token_public_only_read_only) { auth_public_only_read_only.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  before do
    @aspect = auth_read_only.user.aspects.create(name: "new aspect")
    auth_read_only.user.share_with(auth_public_only_read_only.user.person, @aspect)

    @created_status = auth_read_only.user.post(
      :status_message,
      text:   "This is a status message #test @{#{auth_read_only.user.diaspora_handle}}",
      public: true
    )
    comment_service(auth_read_only.user).create(@created_status.guid, "Comment")
    auth_read_only.user.like!(@created_status)
    @status = PostService.new(auth_read_only.user).find(@created_status.id)

    @private_post = auth_read_only.user.post(
      :status_message,
      text:   "This is a private status message #test @{#{auth_read_only.user.diaspora_handle}}",
      public: false,
      to:     @aspect.id
    )
    comment_service(auth_read_only.user).create(@private_post.guid, "Comment")
    auth_read_only.user.like!(@private_post)

    @created_status2 = auth_public_only_read_only.user.post(
      :status_message,
      text:   "This is a status message #test @{#{auth_public_only_read_only.user.diaspora_handle}}",
      public: true
    )
    auth_public_only_read_only.user.like!(@created_status2)
    comment_service(auth_public_only_read_only.user).create(@created_status2.guid, "Comment")
    @created_status3 = auth_public_only_read_only.user.post(
      :status_message,
      text:   "This is a status message #test @{#{auth_public_only_read_only.user.diaspora_handle}}",
      public: false,
      to:     "all"
    )
    auth_public_only_read_only.user.like!(@created_status3)
    comment_service(auth_public_only_read_only.user).create(@created_status3.guid, "Comment")

    add_tag("test", auth_read_only.user)
    add_tag("test", auth_public_only_tags.user)
  end

  describe "#aspect" do
    it "returns a valid schema" do
      get(
        api_v1_aspects_stream_path(aspect_ids: JSON.generate([@aspect.id])),
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)

      posts = response_body_data(response)

      expect(posts.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/posts")
    end

    it "contains expected aspect message" do
      get(
        api_v1_aspects_stream_path(aspect_ids: JSON.generate([@aspect.id])),
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)
      expect(posts.length).to eq 3
      json_post = posts.select {|p| p["guid"] == @status.guid }.first
      confirm_post_format(json_post, auth_read_only.user, @status)
    end

    it "all aspects expected aspect message" do
      get(
        api_v1_aspects_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(3)
      json_post = post.select {|p| p["guid"] == @status.guid }.first
      confirm_post_format(json_post, auth_read_only.user, @status)
    end

    it "does not save to requested aspects to session" do
      get(
        api_v1_aspects_stream_path(a_ids: [@aspect.id]),
        params: {access_token: access_token_read_only}
      )
      expect(session[:a_ids]).to be_nil
    end

    it "fails without impromper credentials" do
      get(
        api_v1_aspects_stream_path(a_ids: [@aspect.id]),
        params: {access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(403)
    end

    it "fails with invalid credentials" do
      get(
        api_v1_aspects_stream_path(a_ids: [@aspect.id]),
        params: {access_token: invalid_token}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "#tags" do
    it "all tags expected" do
      get(
        api_v1_followed_tags_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)
      expect(posts.length).to eq(3)

      expect(posts.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/posts")
    end

    it "public posts only tags expected" do
      get(
        api_v1_followed_tags_stream_path,
        params: {access_token: access_token_public_only_tags}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(2)
    end

    it "fails with improper credentials" do
      get(
        api_v1_followed_tags_stream_path,
        params: {access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(403)
    end

    it "fails with invalid credentials" do
      get(
        api_v1_followed_tags_stream_path,
        params: {access_token: "999_999_999"}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "#activity" do
    it "returns a valid schema" do
      get(
        api_v1_activity_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)

      expect(posts.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/posts")
    end

    it "contains activity message" do
      get(
        api_v1_activity_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(2)
      json_post = post.select {|p| p["guid"] == @status.guid }.first
      confirm_post_format(json_post, auth_read_only.user, @status)
    end

    it "public posts only expected" do
      get(
        api_v1_activity_stream_path,
        params: {access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(1)
    end

    it "fails with invalid credentials" do
      get(
        api_v1_activity_stream_path,
        params: {access_token: invalid_token}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "#main" do
    it "returns a valid schema" do
      get(
        api_v1_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)

      expect(posts.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/posts")
    end

    it "contains main message" do
      get(
        api_v1_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(3)
      json_post = post.select {|p| p["guid"] == @status.guid }.first
      confirm_post_format(json_post, auth_read_only.user, @status)
    end

    it "public posts only expected" do
      get(
        api_v1_stream_path,
        params: {access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(1)
    end

    it "fails with invalid credentials" do
      get(
        api_v1_stream_path,
        params: {access_token: invalid_token}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "#commented" do
    it "returns a valid schema" do
      get(
        api_v1_commented_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)

      expect(posts.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/posts")
    end

    it "contains commented message" do
      get(
        api_v1_commented_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(2)
    end

    it "public posts only expected" do
      get(
        api_v1_commented_stream_path,
        params: {access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(1)
    end

    it "fails with invalid credentials" do
      get(
        api_v1_commented_stream_path,
        params: {access_token: invalid_token}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "#mentions" do
    it "returns a valid schema" do
      get(
        api_v1_mentions_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)

      expect(posts.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/posts")
    end

    it "contains mentions message" do
      get(
        api_v1_mentions_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(2)
    end

    it "public posts only expected" do
      get(
        api_v1_mentions_stream_path,
        params: {access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(1)
    end

    it "fails with invalid credentials" do
      get(
        api_v1_mentions_stream_path,
        params: {access_token: invalid_token}
      )
      expect(response.status).to eq(401)
    end
  end

  describe "#liked" do
    it "returns a valid schema" do
      get(
        api_v1_liked_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      posts = response_body_data(response)

      expect(posts.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/posts")
    end

    it "contains liked message" do
      get(
        api_v1_liked_stream_path,
        params: {access_token: access_token_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(2)
      json_post = post.select {|p| p["guid"] == @status.guid }.first
      confirm_post_format(json_post, auth_read_only.user, @status)
    end

    it "public posts only expected" do
      get(
        api_v1_liked_stream_path,
        params: {access_token: access_token_public_only_read_only}
      )
      expect(response.status).to eq(200)
      post = response_body_data(response)
      expect(post.length).to eq(1)
    end

    it "fails with invalid credentials" do
      get(
        api_v1_liked_stream_path,
        params: {access_token: invalid_token}
      )
      expect(response.status).to eq(401)
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def confirm_post_format(post, user, reference_post, mentions=[])
    confirm_post_top_level(post, reference_post)
    confirm_person_format(post["author"], user)
    confirm_interactions(post["interaction_counters"], reference_post)

    mentions.each do |mention|
      post_mentions = post["mentioned_people"]
      post_mention = post_mentions.find {|m| m["guid"] == mention.guid }
      confirm_person_format(post_mention, mention)
    end

    confirm_poll(post["poll"], reference_post.poll, false) if reference_post.poll
    confirm_location(post["location"], reference_post.location) if reference_post.location
    confirm_photos(post["photos"], reference_post.photos) if reference_post.photos
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
    expect(location["lat"]).to eq(ref_location[:lat])
    expect(location["lng"]).to eq(ref_location[:lng])
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

  def confirm_reshare_format(post, root_post, root_poster)
    root = post["root"]
    expect(root.has_key?("guid")).to be_truthy
    expect(root["guid"]).to eq(root_post[:guid])
    expect(root.has_key?("created_at")).to be_truthy
    confirm_person_format(root["author"], root_poster)
  end
  # rubocop:enable Metrics/AbcSize

  def response_body_data(response)
    JSON.parse(response.body)
  end

  def add_tag(name, user)
    tag = ActsAsTaggableOn::Tag.find_or_create_by(name: name)
    tag_following = user.tag_followings.new(tag_id: tag.id)
    tag_following.save
    tag_following
  end

  def comment_service(user)
    CommentService.new(user)
  end
end
