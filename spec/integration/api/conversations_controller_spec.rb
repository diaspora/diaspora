require "spec_helper"


describe Api::V0::ConversationsController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }

  before do
    auth.user.share_with bob.person, auth.user.aspects[0]
    auth.user.share_with alice.person, auth.user.aspects[0]
    alice.share_with auth.user.person, alice.aspects[0]

    @conversation = {
      author_id: auth.user.id,
      subject: "new conversation",
      text: "first message",
      messages: [{
        text: "first message"
      }],
      recipients: [alice.person.id],
      access_token: access_token
    }
  end

  describe "#create" do
    context "with valid data" do
      it "creates the conversation" do
        post(
          api_v0_conversations_path(), 
          @conversation
        )
        expect(response.status).to eq 201
        response_body = JSON.parse(response.body)["conversation"]
        expect(response_body["messages"][0]["id"]).to_not be_nil
        expect(response_body["id"]).to_not be_nil
        expect(response_body["participants"].length).to eq 2
      end
    end

    context "without valid data" do
      it "fails at creating the conversation" do
        post api_v0_conversations_path(), { :access_token => access_token }
        expect(response.status).to eq 400
      end
    end
  end

  describe "#index" do
    before do
      post api_v0_conversations_path(), @conversation
      post api_v0_conversations_path(), @conversation
    end

    it "returns all the user conversations" do
      get api_v0_conversations_path(), access_token: access_token
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).length).to eq 2
    end
  end

  describe "#show" do
    context "valid conversation ID" do
      before do
        post api_v0_conversations_path(), @conversation
      end

      it "returns the corresponding conversation" do
        conversation_id = JSON.parse(response.body)["conversation"]["id"]
        get(
          api_v0_conversation_path(conversation_id), 
          access_token: access_token
        )
        expect(response.status).to eq 200
        result_id = JSON.parse(response.body)["conversation"]["id"]
        expect(result_id).to eq conversation_id
      end
    end

    context "non existing conversation ID" do
      it "returns a not found error (404)" do
        get(
          api_v0_conversation_path(42), 
          access_token: access_token
        )
        expect(response.status).to eq 404
      end
    end
  end

  describe "#delete" do
    context "valid conversation ID" do
      before do
        post api_v0_conversations_path(), @conversation
      end

      it "deletes the conversation" do
        conversation_id = JSON.parse(response.body)["conversation"]["id"]
        delete(
          api_v0_conversation_path(conversation_id), 
          access_token: access_token
        )
        expect(response.status).to eq 204
        get(
          api_v0_conversation_path(conversation_id), 
          access_token: access_token
        )
        expect(response.status).to eq 404
      end

    end
    context "non existing conversation ID" do
      it "returns a not found error (404)" do
        delete(
          api_v0_conversation_path(42), 
          access_token: access_token
        )
        expect(response.status).to eq 404
      end
    end
  end

end
