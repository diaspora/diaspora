# frozen_string_literal: true

module Workers
  class ReceiveLocal < Base
    sidekiq_options queue: :high

    def perform(object_class_string, object_id, recipient_user_ids)
      object = object_class_string.constantize.find(object_id)

      object.receive(recipient_user_ids) if object.respond_to?(:receive)

      NotificationService.new.notify(object, recipient_user_ids)
    rescue ActiveRecord::RecordNotFound # Already deleted before the job could run
    end
  end
end
