# frozen_string_literal: true

require_relative "api_spec_helper"

describe Api::V1::MessagesController do
  let(:auth) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid conversations],
      user:   FactoryGirl.create(:user, profile: FactoryGirl.create(:profile_with_image_url))
    )
  }

  let(:auth_minimum_scopes) {
    FactoryGirl.create(:auth_with_default_scopes)
  }

  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_minimum_scopes) { auth_minimum_scopes.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  before do
    auth.user.seed_aspects
    auth.user.share_with(bob.person, auth.user.aspects[0])
    auth.user.share_with(alice.person, auth.user.aspects[0])
    auth.user.share_with(auth_minimum_scopes.user.person, auth.user.aspects[0])
    alice.share_with auth.user.person, alice.aspects[0]
    auth_minimum_scopes.user.seed_aspects
    auth_minimum_scopes.user.share_with(auth.user.person, auth_minimum_scopes.user.aspects[0])

    @conversation = {
      subject:      "new conversation",
      body:         "first message",
      recipients:   [alice.guid],
      access_token: access_token
    }

    @message_text = "reply to first message"
  end

  describe "#create" do
    before do
      post api_v1_conversations_path, params: @conversation
      @conversation_guid = JSON.parse(response.body)["guid"]
    end

    context "with valid data" do
      it "creates the message in the conversation scope" do
        post(
          api_v1_conversation_messages_path(@conversation_guid),
          params: {body: @message_text, access_token: access_token}
        )
        expect(response.status).to eq(201)

        message = JSON.parse(response.body)
        confirm_message_format(message, @message_text, auth.user)

        get(
          api_v1_conversation_messages_path(@conversation_guid),
          params: {access_token: access_token}
        )
        messages = response_body_data(response)
        expect(messages.length).to eq(2)
        confirm_message_format(messages[1], @message_text, auth.user)
      end
    end

    context "without valid data" do
      it "no data returns a unprocessable entity (422)" do
        post(
          api_v1_conversation_messages_path(@conversation_guid),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 422, "Couldn’t accept or process the conversation")
      end

      it "empty string returns a unprocessable entity (422)" do
        post(
          api_v1_conversation_messages_path(@conversation_guid),
          params: {body: "", access_token: access_token}
        )
        confirm_api_error(response, 422, "Couldn’t accept or process the conversation")
      end
    end

    context "with wrong conversation id" do
      it "returns a a not found error (404)" do
        post(
          api_v1_conversation_messages_path(42),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Conversation with provided guid could not be found")
      end
    end

    context "improper credentials" do
      it "fails without conversation token" do
        post(
          api_v1_conversation_messages_path(@conversation_guid),
          params: {body: @message_text, access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(403)
      end

      it "fails when not logged in" do
        post(
          api_v1_conversation_messages_path(@conversation_guid),
          params: {body: @message_text, access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#index" do
    before do
      post api_v1_conversations_path, params: @conversation
      @conversation_guid = JSON.parse(response.body)["guid"]
    end

    context "retrieving messages" do
      it "returns all messages related to conversation" do
        get(
          api_v1_conversation_messages_path(@conversation_guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        messages = response_body_data(response)
        expect(messages.length).to eq(1)

        expect(messages.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/messages")

        confirm_message_format(messages[0], "first message", auth.user)
        conversation = get_conversation(@conversation_guid)
        expect(conversation[:read]).to be_truthy
      end

      context "improper credentials" do
        it "fails without conversation token" do
          get(
            api_v1_conversation_messages_path(@conversation_guid),
            params: {access_token: access_token_minimum_scopes}
          )
          expect(response.status).to eq(403)
        end

        it "fails when not logged in" do
          get(
            api_v1_conversation_messages_path(@conversation_guid),
            params: {access_token: invalid_token}
          )
          expect(response.status).to eq(401)
        end
      end
    end
  end

  private

  def response_body_data(response)
    JSON.parse(response.body)
  end

  def get_conversation(conversation_id)
    conversation_service = ConversationService.new(auth.user)
    raw_conversation = conversation_service.find!(conversation_id)
    ConversationPresenter.new(raw_conversation, auth.user).as_api_json
  end

  def confirm_message_format(message, ref_message, author)
    expect(message["guid"]).to_not be_nil
    expect(message["created_at"]).to_not be_nil
    expect(message["body"]).to eq ref_message
    confirm_person_format(message["author"], author)
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
