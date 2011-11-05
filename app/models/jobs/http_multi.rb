#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'uri'
require 'resque-retry'
require File.join(Rails.root, 'lib/hydra_wrapper')

module Jobs
  class HttpMulti < Base
    extend Resque::Plugins::ExponentialBackoff

    @queue = :http
    @backoff_strategy =   [10.minutes,
                          3.hours,
                         12.hours,
                          2.days]

    def self.args_for_retry(user_id, encoded_object_xml, person_ids, dispatcher_class_as_string)
      [user_id, encoded_object_xml, @failed_people, dispatcher_class_as_string]
    end

    def self.perform(user_id, encoded_object_xml, person_ids, dispatcher_class_as_string)
      user = User.find(user_id)

      #could be bad here
      people = Person.where(:id => person_ids)

      dispatcher = dispatcher_class_as_string.constantize
      hydra = HydraWrapper.new(user, people, encoded_object_xml, dispatcher)

      hydra.enqueue_batch
      hydra.run

      @failed_people = hydra.failed_people

      unless @failed_people.empty?
        if self.retry_limit_reached?
          msg = "event=http_multi_abandon sender_id=#{user_id} failed_recipient_ids='[#{@failed_people.join(', ')}]'"
          Rails.logger.info(msg)
        else
          raise 'retry'
        end
      end
    end
  end
end
