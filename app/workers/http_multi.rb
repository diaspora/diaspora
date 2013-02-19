#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class HttpMulti < Base
    sidekiq_options queue: :http

    MAX_RETRIES = 3

    def perform(user_id, encoded_object_xml, person_ids, dispatcher_class_as_string, retry_count=0)
      user = User.find(user_id)
      people = Person.where(:id => person_ids)

      dispatcher = dispatcher_class_as_string.constantize
      hydra = HydraWrapper.new(user, people, encoded_object_xml, dispatcher)

      hydra.enqueue_batch
      hydra.run

      unless hydra.failed_people.empty?
        if retry_count < MAX_RETRIES
          Workers::HttpMulti.perform_in(1.hour, user_id, encoded_object_xml, hydra.failed_people, dispatcher_class_as_string, retry_count + 1)
        else
          Rails.logger.info("event=http_multi_abandon sender_id=#{user_id} failed_recipient_ids='[#{person_ids.join(', ')}] '")
        end
      end
    end
  end
end




