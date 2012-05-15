#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class PublishToHub < Base
    @queue = :http_service
    def self.perform(sender_public_url)
      # don't publish to pubsubhubbub in cucumber
    end
  end

  class HttpMulti < Base
    @queue = :http
    def self.perform(user_id, enc_object_xml, person_ids, retry_count=0)
      # don't federate in cucumber
    end
  end

  class HttpPost < Base
    @queue = :http
    def self.perform(url, body, tries_remaining = NUM_TRIES)
      # don't post to outside services in cucumber
    end
  end

  class PostToService < Base
    @queue = :http_service
    def self.perform(service_id, post_id, url)
      # don't post to services in cucumber
    end
  end
end