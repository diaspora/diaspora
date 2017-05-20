require "spec_helper"

describe Api::V0::ConversationVisibilitiesController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let(:auth_participant) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_participant) { auth_participant.create_access_token.to_s }

  before do
    auth.user.seed_aspects
    auth.user.share_with auth_participant.user.person, auth.user.aspects[1]
    auth_participant.user.share_with(
      auth.user.person, auth_participant.user.aspects[0]
    )

    @conversation = {
      author_id:    auth.user.id,
      subject:      "new conversation",
      text:         "first message",
      messages:     [{
        author: auth.user,
        text:   "first message"
      }],
      recipients:   [auth_participant.user.person.id],
      access_token: access_token
    }
  end

  describe "#destroy " do
    before do
      post api_v0_conversations_path, @conversation
      @conversation_id = JSON.parse(response.body)["conversation"]["id"]
    end

    context "destroy" do
      it "destroys the first participant visibility" do
        delete(
          api_v0_conversation_visibility_path(@conversation_id),
          access_token: access_token
        )
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)["message"]).to_not be_nil

        get api_v0_conversation_path(
          @conversation_id,
          access_token: access_token
        )
        expect(response.status).to eq 404

        get api_v0_conversation_path(
          @conversation_id,
          access_token: access_token_participant
        )
        expect(response.status).to eq 200
      end
    end

    context "destroy again" do
      it "destroys the second participant visibilty and the conversation" do
        delete(
          api_v0_conversation_visibility_path(@conversation_id),
          access_token: access_token
        )
        delete(
          api_v0_conversation_visibility_path(@conversation_id),
          access_token: access_token_participant
        )
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)["message"]).to_not be_nil

        get api_v0_conversation_path(
          @conversation_id,
          access_token: access_token_participant
        )
        expect(response.status).to eq 404

        expect {
          Conversation.find(@conversation_id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
