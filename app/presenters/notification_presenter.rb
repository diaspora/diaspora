# frozen_string_literal: true

class NotificationPresenter < BasePresenter
  def as_api_json
    data = base_hash
    data = data.merge(target: target_json) if target
    data
  end

  private

  def base_hash
    {
      guid:           guid,
      type:           type_as_json,
      read:           !unread,
      created_at:     created_at,
      event_creators: creators_json
    }
  end

  def target_json
    json = {guid: target.guid}
    json[:author] = PersonPresenter.new(target.author).as_api_json if target.author
    json
  end

  def creators_json
    actors.map {|actor| PersonPresenter.new(actor).as_api_json }
  end

  def type_as_json
    NotificationService::NOTIFICATIONS_REVERSE_JSON_TYPES[type]
  end

  def target
    return linked_object if linked_object&.is_a?(Post)
    return linked_object.post if linked_object&.respond_to?(:post)
  end
end
