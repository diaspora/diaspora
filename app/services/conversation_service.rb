class ConversationService

  def initialize(user=nil)
    @user = user
  end

  def all_for_user()
    Conversation.where(author_id: @user.person.id).all
  end

  def build(subject, text, recipients)
    person_ids = @user
      .contacts
      .mutual
      .where(:person_id => recipients)
      .pluck(:person_id)

    opts = {
      subject: subject,
      message: { text: text },
      participant_ids: person_ids
    }

    @user.build_conversation(opts)
  end

  def find!(conversation_id)
    @user.conversations
      .joins(:conversation_visibilities)
      .where(conversation_visibilities: {
        person_id: @user.person_id,
        conversation_id: conversation_id
      }).first!
  end

  def destroy!(conversation_id)
    conversation = find!(conversation_id)
    conversation.destroy!
  end

  def get_visibility(conversation_id)
    ConversationVisibility.where(
      :person_id => @user.person.id,
      :conversation_id => conversation_id
    ).first!
  end

end
