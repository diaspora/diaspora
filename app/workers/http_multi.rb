#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class HttpMulti < Base
    sidekiq_options queue: :http

    MAX_RETRIES = 3
    ABANDON_ON_CODES=[:peer_failed_verification, # Certificate does not match URL
                      :ssl_connect_error, # Problem negotiating ssl version or Cert couldn't be verified (often self-signed)
                      :ssl_cacert, # Expired SSL cert
                      ]
    def perform(user_id, encoded_object_xml, person_ids, dispatcher_class_as_string, retry_count=0)
      user = User.find(user_id)
      people = Person.where(:id => person_ids)

      dispatcher = dispatcher_class_as_string.constantize
      hydra = HydraWrapper.new(user, people, encoded_object_xml, dispatcher)

      hydra.enqueue_batch

      hydra.keep_for_retry_if do |response|
        !ABANDON_ON_CODES.include?(response.return_code)
      end

      hydra.run


      unless hydra.people_to_retry.empty?
        if retry_count < MAX_RETRIES
          Workers::HttpMulti.perform_in(1.hour, user_id, encoded_object_xml, hydra.people_to_retry, dispatcher_class_as_string, retry_count + 1)
        else
          Rails.logger.info("event=http_multi_abandon sender_id=#{user_id} failed_recipient_ids='[#{person_ids.join(', ')}] '")
        end
      end
    end
  end
end




