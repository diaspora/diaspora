# frozen_string_literal: true

module Workers
  class SendPrivate < SendBase
    def perform(sender_id, obj_str, targets, retry_count=0)
      targets_to_retry = DiasporaFederation::Federation::Sender.private(sender_id, obj_str, targets)

      return if targets_to_retry.empty?

      schedule_retry(retry_count + 1, sender_id, obj_str, targets_to_retry.keys) do |delay, new_retry_count|
        Workers::SendPrivate.perform_in(delay, sender_id, obj_str, targets_to_retry, new_retry_count)
      end
    end
  end
end
