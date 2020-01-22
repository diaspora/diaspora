# frozen_string_literal: true

class ConversationPresenter < BasePresenter
  def as_api_json
    read = @presentable.conversation_visibilities.find_by(person_id: current_user.person_id)&.unread == 0
    {
      guid:         @presentable.guid,
      subject:      @presentable.subject,
      created_at:   @presentable.created_at,
      read:         read,
      participants: @presentable.participants.map {|x| PersonPresenter.new(x).as_api_json }
    }
  end
end
