class ConversationPresenter < BasePresenter
  def initialize(conversation)
    @conversation = conversation
  end

  def as_json(opts={})
    {
      id:           @conversation.id,
      guid:         @conversation.guid,
      created_at:   @conversation.created_at,
      subject:      @conversation.subject,
      messages:     @conversation.messages.map { |x| x.as_json["message"] },
      author:       @conversation.author,
      participants: @conversation.participants
    }
  end
end
