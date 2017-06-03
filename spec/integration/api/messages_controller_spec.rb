require "spec_helper"

describe Api::V0::MessagesController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }

  before do
    auth.user.seed_aspects
    auth.user.share_with bob.person, auth.user.aspects[1]
    auth.user.share_with alice.person, auth.user.aspects[1]
    alice.share_with auth.user.person, alice.aspects[0]

    @conversation = {
      author_id:    auth.user.id,
      subject:      "new conversation",
      body:         "first message",
      recipients:   [alice.person.id],
      access_token: access_token
    }

    @message = {
      body: "reply to first message"
    }
  end

  describe "#create " do
    before do
      post api_v0_conversations_path, @conversation
      @conversation_guid = JSON.parse(response.body)["conversation"]["guid"]
    end

    context "with valid data" do
      it "creates the message in the conversation scope" do
        post(
          api_v0_conversation_messages_path(@conversation_guid),
          body: @message, access_token: access_token
        )
        expect(response.status).to eq 201

        message = JSON.parse(response.body)
        expect(message["guid"]).to_not be_nil
        expect(message["author"]).to_not be_nil
        expect(message["created_at"]).to_not be_nil
        expect(message["body"]).to_not be_nil

        get(
          api_v0_conversation_messages_path(@conversation_guid),
          access_token: access_token
        )
        messages = JSON.parse(response.body)
        expect(messages.length).to eq 2
        text = messages[1]["body"]
        expect(text).to eq @message[:body]
      end
    end

    context "without valid data" do
      it "returns a wrong parameter error (400)" do
        post(
          api_v0_conversation_messages_path(@conversation_guid),
          access_token: access_token
        )
        expect(response.status).to eq 400
      end
    end

    context "with wrong conversation id" do
      it "returns a a not found error (404)" do
        post(
          api_v0_conversation_messages_path(42),
          access_token: access_token
        )
        expect(response.status).to eq 404
      end
    end
  end

  describe "#index " do
    before do
      post api_v0_conversations_path, @conversation
      @conversation_guid = JSON.parse(response.body)["conversation"]["guid"]
    end

    context "retrieving messages" do
      it "returns all messages related to conversation" do
        get(
          api_v0_conversation_messages_path(@conversation_guid),
          access_token: access_token
        )
        messages = JSON.parse(response.body)
        expect(messages.length).to eq 1

        message = messages[0]
        expect(message["guid"]).to_not be_nil
        expect(message["author"]).to_not be_nil
        expect(message["created_at"]).to_not be_nil
        expect(message["body"]).to_not be_nil
      end
    end
  end

end
