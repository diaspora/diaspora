# frozen_string_literal: true

class SendPublicWorker < SendBaseWorker
  def perform(sender_id, obj_str, urls, xml, retry_count=0)
    urls_to_retry = DiasporaFederation::Federation::Sender.public(sender_id, obj_str, urls, xml)

    return if urls_to_retry.empty?

    schedule_retry(retry_count + 1, sender_id, obj_str, urls_to_retry) do |delay, new_retry_count|
      SendPublicWorker.perform_in(delay, sender_id, obj_str, urls_to_retry, xml, new_retry_count)
    end
  end
end
