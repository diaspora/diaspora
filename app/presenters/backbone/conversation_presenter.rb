
class Backbone::ConversationPresenter < BasePresenter
  # base hash contains only direct attributes, no associated or delegated ones
  # include only items needed for *presentation*
  def base_hash
    { id: id,
      guid: guid,
      subject: subject,
      updated_at: updated_at
    }
  end

  # full hash includes the base hash and associated or delegated attributes
  def full_hash
    base_hash.merge({
      author: AuthorPresenter.new(author).full_hash,
      last_author: AuthorPresenter.new(last_author).full_hash,
      message_count: messages.size,
      participant_count: participants.size,
      participants: AuthorPresenter.as_collection(participants, :full_hash)
    })
  end

end
