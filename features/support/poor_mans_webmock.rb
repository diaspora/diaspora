#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class PublishToHub < Base
    def perform(sender_public_url)
      # don't publish to pubsubhubbub in cucumber
    end
  end

  class HttpMulti < Base
    def perform(user_id, enc_object_xml, person_ids, retry_count=0)
      # don't federate in cucumber
    end
  end

  class HttpPost < Base
    def perform(url, body, tries_remaining = NUM_TRIES)
      # don't post to outside services in cucumber
    end
  end

  class PostToService < Base
    def perform(service_id, post_id, url)
      # don't post to services in cucumber
    end
  end
end
