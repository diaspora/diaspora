class ConversationService
  def initialize(user=nil)
    @user = user
  end

  def all_for_user(filter={})
    conversation_filter = {}
    if !filter[:only_after].nil? then
      conversation_filter = \
        'conversations.created_at >= ?', filter[:only_after]
    end

    visibility_filter = {person_id: @user.person_id}
    if filter[:unread] == true then
      visibility_filter["unread"] = 0
    end

    Conversation.where(conversation_filter)
                .joins(:conversation_visibilities)
                .where(conversation_visibilities: visibility_filter)
                .all
  end

  def build(subject, text, recipients)
    person_ids = @user.contacts
                      .mutual
                      .where(person_id: recipients)
                      .pluck(:person_id)

    opts = {
      subject:         subject,
      message:         {text: text},
      participant_ids: person_ids
    }

    @user.build_conversation(opts)
  end

  def find!(conversation_guid)
    conversation = Conversation.find_by!({guid: conversation_guid})
    @user.conversations
         .joins(:conversation_visibilities)
         .where(conversation_visibilities: {
                  person_id:       @user.person_id,
                  conversation_id: conversation.id
                }).first!
  end

  def destroy!(conversation_guid)
    conversation = find!(conversation_guid)
    conversation.destroy!
  end

  def get_visibility(conversation_guid)
    conversation = find!(conversation_guid)
    ConversationVisibility.where(
      person_id:       @user.person.id,
      conversation_id: conversation.id
    ).first!
  end
end
