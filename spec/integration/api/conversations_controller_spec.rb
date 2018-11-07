# frozen_string_literal: true

require "spec_helper"

describe Api::V1::ConversationsController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }
  let(:auth_participant) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token_participant) { auth_participant.create_access_token.to_s }

  before do
    auth.user.share_with alice.person, auth.user.aspects[0]
    alice.share_with auth.user.person, alice.aspects[0]
    auth.user.disconnected_by(eve)

    @conversation = {
      subject:      "new conversation",
      body:         "first message",
      recipients:   JSON.generate([alice.guid]),
      access_token: access_token
    }
  end

  describe "#create" do
    context "with valid data" do
      it "creates the conversation" do
        post api_v1_conversations_path, params: @conversation
        expect(response.status).to eq 201
        conversation = JSON.parse(response.body)
        confirm_conversation_format(conversation, @conversation, [auth.user, alice])
      end
    end

    context "without valid data" do
      it "fails with empty body" do
        post api_v1_conversations_path, params: {access_token: access_token}
        expect(response.status).to eq 422
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.cant_process"))
      end

      it "fails with missing subject " do
        incomplete_convo = {
          body:         "first message",
          recipients:   [alice.guid],
          access_token: access_token
        }
        post api_v1_conversations_path, params: incomplete_convo
        expect(response.status).to eq 422
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.cant_process"))
      end

      it "fails with missing body " do
        incomplete_convo = {
          subject:      "new conversation",
          recipients:   [alice.guid],
          access_token: access_token
        }
        post api_v1_conversations_path, params: incomplete_convo
        expect(response.status).to eq 422
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.cant_process"))
      end

      it "fails with missing recipients " do
        incomplete_convo = {
          subject:      "new conversation",
          body:         "first message",
          access_token: access_token
        }
        post api_v1_conversations_path, params: incomplete_convo
        expect(response.status).to eq 422
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.cant_process"))
      end

      it "fails with bad recipient ID " do
        incomplete_convo = {
          subject:      "new conversation",
          body:         "first message",
          recipients:   JSON.generate(["999_999_999"]),
          access_token: access_token
        }
        post api_v1_conversations_path, params: incomplete_convo
        expect(response.status).to eq 422
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.cant_process"))
      end

      it "fails with invalid recipient (not allowed to message) " do
        incomplete_convo = {
          subject:      "new conversation",
          body:         "first message",
          recipients:   JSON.generate([eve.guid]),
          access_token: access_token
        }
        post api_v1_conversations_path, params: incomplete_convo
        expect(response.status).to eq 422
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.cant_process"))
      end
    end
  end

  describe "#index" do
    before do
      post api_v1_conversations_path, params: @conversation
      post api_v1_conversations_path, params: @conversation
      sleep(1)
      post api_v1_conversations_path, params: @conversation
      conversation_guid = JSON.parse(response.body)["guid"]
      conversation = conversation_service.find!(conversation_guid)
      conversation.conversation_visibilities[0].unread = 1
      conversation.conversation_visibilities[0].save!
      conversation.conversation_visibilities[1].unread = 1
      conversation.conversation_visibilities[1].save!
      @date = conversation.created_at
    end

    it "returns all the user conversations" do
      get api_v1_conversations_path, params: {access_token: access_token}
      expect(response.status).to eq 200
      returned_convos = JSON.parse(response.body)
      expect(returned_convos.length).to eq 3
      confirm_conversation_format(returned_convos[0], @conversation, [auth.user, alice])
    end

    it "returns all the user unread conversations" do
      get(
        api_v1_conversations_path,
        params: {only_unread: true, access_token: access_token}
      )
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).length).to eq 2
    end

    it "returns all the user conversations after a given date" do
      get(
        api_v1_conversations_path,
        params: {only_after: @date, access_token: access_token}
      )
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).length).to eq 1
    end
  end

  describe "#show" do
    context "valid conversation ID" do
      before do
        post api_v1_conversations_path, params: @conversation
      end

      it "returns the corresponding conversation" do
        conversation_guid = JSON.parse(response.body)["guid"]
        get(
          api_v1_conversation_path(conversation_guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq 200
        conversation = JSON.parse(response.body)
        confirm_conversation_format(conversation, @conversation, [auth.user, alice])
      end
    end

    context "non existing conversation ID" do
      it "returns a not found error (404)" do
        get(
          api_v1_conversation_path(42),
          params: {access_token: access_token}
        )
        expect(response.status).to eq 404
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.not_found"))
      end
    end
  end

  describe "#destroy " do
    before do
      auth.user.seed_aspects
      auth.user.share_with auth_participant.user.person, auth.user.aspects[1]
      auth_participant.user.share_with(
        auth.user.person, auth_participant.user.aspects[0]
      )

      @conversation = {
        subject:      "new conversation",
        body:         "first message",
        recipients:   JSON.generate([auth_participant.user.guid]),
        access_token: access_token
      }
      post api_v1_conversations_path, params: @conversation
      @conversation_guid = JSON.parse(response.body)["guid"]
    end

    context "destroy" do
      it "destroys the first participant visibility" do
        delete(
          api_v1_conversation_path(@conversation_guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq 204
        get api_v1_conversation_path(
          @conversation_guid,
          params: {access_token: access_token}
        )
        expect(response.status).to eq 404
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.not_found"))
        get api_v1_conversation_path(
          @conversation_guid,
          params: {access_token: access_token_participant}
        )
        expect(response.status).to eq 200
      end
    end

    context "destroy all visibilities" do
      it "destroys the second participant visibilty and the conversation" do
        delete(
          api_v1_conversation_path(@conversation_guid),
          params: {access_token: access_token}
        )
        delete(
          api_v1_conversation_path(@conversation_guid),
          params: {access_token: access_token_participant}
        )
        expect(response.status).to eq 204

        get api_v1_conversation_path(
          @conversation_guid,
          params: {access_token: access_token_participant}
        )
        expect(response.status).to eq 404
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.not_found"))

        expect {
          Conversation.find(guid: @conversation_guid)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "non existing conversation ID" do
      it "returns a not found error (404)" do
        delete(
          api_v1_conversation_path(42),
          params: {access_token: access_token}
        )
        expect(response.status).to eq 404
        expect(response.body).to eq(I18n.t("api.endpoint_errors.conversations.not_found"))
      end
    end
  end

  def conversation_service
    ConversationService.new(alice)
  end

  private

  # rubocop:disable Metrics/AbcSize
  def confirm_conversation_format(conversation, ref_convo, ref_participants)
    expect(conversation["guid"]).to_not be_nil
    conversation_service.find!(conversation["guid"])
    expect(conversation["subject"]).to eq ref_convo[:subject]
    expect(conversation["created_at"]).to_not be_nil
    expect(conversation["read"]).to be_truthy
    expect(conversation["participants"].length).to eq(ref_participants.length)
    participants = conversation["participants"]

    expect(participants.length).to eq(ref_participants.length)
    ref_participants.each do |p|
      conversation_participant = participants.find {|cp| cp["guid"] == p.guid }
      confirm_person_format(conversation_participant, p)
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def confirm_person_format(post_person, user)
    expect(post_person["guid"]).to eq(user.guid)
    expect(post_person["diaspora_id"]).to eq(user.diaspora_handle)
    expect(post_person["name"]).to eq(user.name)
    expect(post_person["avatar"]).to eq(user.profile.image_url)
  end
  # rubocop:enable Metrics/AbcSize
end
