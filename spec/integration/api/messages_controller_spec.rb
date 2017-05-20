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
      text:         "first message",
      messages:     [{
        author: auth.user,
        text:   "first message"
      }],
      recipients:   [alice.person.id],
      access_token: access_token
    }

    @message = {
      text: "reply to first message"
    }
  end

  describe "#create " do
    before do
      post api_v0_conversations_path, @conversation
      @conversation_id = JSON.parse(response.body)["conversation"]["id"]
    end

    context "with valid data" do
      it "creates the message in the conversation scope" do
        post(
          api_v0_conversation_messages_path(@conversation_id),
          message: @message, access_token: access_token
        )
        expect(response.status).to eq 201
        expect(JSON.parse(response.body)["message"]["id"]).to_not be_nil
        get(
          api_v0_conversation_path(@conversation_id),
          access_token: access_token
        )
        response_body = JSON.parse(response.body)["conversation"]
        expect(response_body["messages"].length).to eq 2
        text = response_body["messages"][1]["text"]
        expect(text).to eq "reply to first message"
      end
    end

    context "without valid data" do
      it "returns a wrong parameter error (400)" do
        post(
          api_v0_conversation_messages_path(@conversation_id),
          access_token: access_token
        )
        expect(response.status).to eq 400
      end
    end
  end
end
