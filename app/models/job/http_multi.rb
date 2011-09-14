#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'uri'

module Job
  class HttpMulti < Base
    @queue = :http

    MAX_RETRIES = 3

    def self.perform(user_id, encoded_object_xml, person_ids, retry_count=0)
      return true if user_id == '91842' #NOTE 09/08/11 blocking diapsorahqposts

      user = User.find(user_id)
      people = Person.where(:id => person_ids)

      dispatcher = Postzord::Dispatcher::Private
      hydra = HydraWrapper.new(user, people, encoded_object_xml, dispatcher)

      hydra.enqueue_batch
      hydra.run

      unless hydra.failed_people.empty?
        if retry_count < MAX_RETRIES
          Resque.enqueue(Job::HttpMulti, user_id, encoded_object_xml, hydra.failed_people, retry_count + 1 )
        else
          Rails.logger.info("event=http_multi_abandon sender_id=#{user_id} failed_recipient_ids='[#{person_ids.join(', ')}] '")
        end
      end
    end
  end
end




