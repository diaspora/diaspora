# frozen_string_literal: true

describe ConversationService do
  before do
    opts = {
      subject:         "conversation subject",
      message:         {text: "conversation text"},
      participant_ids: [bob.person.id]
    }
    @conversation = alice.build_conversation(opts)
    @conversation.created_at = 2.hours.ago
    @conversation.save!
  end

  describe "#all_for_user" do
    before do
      opts = {
        subject:         "conversation subject 2",
        message:         {text: "conversation text 2"},
        participant_ids: [bob.person.id]
      }
      @conversation = alice.build_conversation(opts)
      @conversation.created_at = 1.hour.ago
      @conversation.save!
      @date = @conversation.created_at
      opts = {
        subject:         "conversation subject 3",
        message:         {text: "conversation text 3"},
        participant_ids: []
      }
      @conversation = bob.build_conversation(opts)
      @conversation.save!
    end

    it "returns all conversations" do
      expect(alice_conversation_service.all_for_user.length).to eq(2)
      expect(bob_conversation_service.all_for_user.length).to eq(3)
    end

    it "returns all unread conversations" do
      @conversation.conversation_visibilities[0].unread = true
      @conversation.conversation_visibilities[0].save!
      conversations = bob_conversation_service.all_for_user(unread: true)
      expect(conversations.length).to eq(1)
    end

    it "returns conversation after a given date" do
      conversations = bob_conversation_service.all_for_user(only_after: @date)
      expect(conversations.length).to eq(2)
    end
  end

  describe "#find!" do
    it "returns the conversation, if it is the user's conversation" do
      expect(bob_conversation_service.find!(@conversation.guid)).to eq(
        @conversation
      )
    end

    it "returns the conversation, if the user is recipient" do
      expect(bob_conversation_service.find!(@conversation.guid)).to eq(
        @conversation
      )
    end

    it "raises RecordNotFound if the conversation cannot be found" do
      expect {
        alice_conversation_service.find!("unknown")
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises RecordNotFound if the user is not recipient" do
      expect {
        eve_conversation_service.find!(@conversation.guid)
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#build" do
    it "creates the conversation for given user and recipients" do
      new_conversation = alice_conversation_service.build(
        "subject test",
        "message test",
        [bob.person.id]
      )
      expect(new_conversation.subject).to eq("subject test")
      expect(new_conversation.author_id).to eq(alice.person.id)
      expect(new_conversation.messages[0].text).to eq("message test")
      expect(new_conversation.messages[0].author_id).to eq(alice.person.id)
      expect(new_conversation.participants.length).to eq(2)
    end

    it "doesn't add recipients if they are not user contacts" do
      new_conversation = alice_conversation_service.build(
        "subject test",
        "message test",
        [bob.person.id, eve.person.id]
      )
      expect(new_conversation.participants.length).to eq(2)
      expect(new_conversation.messages[0].text).to eq("message test")
      expect(new_conversation.messages[0].author_id).to eq(alice.person.id)
    end
  end

  describe "#get_visibility" do
    it "returns visibility for current user" do
      visibility = alice_conversation_service.get_visibility(
        @conversation.guid
      )
      expect(visibility).to_not be_nil
    end

    it "raises RecordNotFound if the user has no visibility" do
      expect {
        eve_conversation_service.get_visibility(@conversation.id)
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#destroy!" do
    it "deletes the conversation, when it is the user conversation" do
      alice_conversation_service.destroy!(@conversation.guid)
      expect {
        alice_conversation_service.find!(@conversation.guid)
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises RecordNotFound if the conversation cannot be found" do
      expect {
        alice_conversation_service.destroy!("unknown")
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises RecordNotFound if the user is not part of the conversation" do
      expect {
        eve_conversation_service.destroy!(@conversation.guid)
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  def alice_conversation_service
    ConversationService.new(alice)
  end

  def bob_conversation_service
    ConversationService.new(bob)
  end

  def eve_conversation_service
    ConversationService.new(eve)
  end
end
