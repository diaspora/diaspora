# frozen_string_literal: true

class NotificationPresenter < BasePresenter
  def as_api_json(include_target=true)
    data = base_hash
    data = data.merge(target: target_json) if include_target && linked_object
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
    json = {guid: linked_object.guid}
    json[:author] = PersonPresenter.new(linked_object.author).as_api_json if linked_object.author
    json
  end

  def creators_json
    actors.map {|actor| PersonPresenter.new(actor).as_api_json }
  end

  def type_as_json
    NotificationService::NOTIFICATIONS_REVERSE_JSON_TYPES[type]
  end
end
