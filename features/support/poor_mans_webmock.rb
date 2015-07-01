#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class PublishToHub < Base
    def perform(_sender_atom_url)
      # don't publish to pubsubhubbub in cucumber
    end
  end

  class HttpMulti < Base
    def perform(_user_id, _enc_object_xml, _person_ids, _retry_count=0)
      # don't federate in cucumber
    end
  end

  class PostToService < Base
    def perform(_service_id, _post_id, _url)
      # don't post to services in cucumber
    end
  end
end
