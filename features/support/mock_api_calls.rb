#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Job
  class PublishToHub < Base
    @queue = :http_service
    def self.perform(sender_public_url)
      # don't publish when in cucumber
    end
  end
end
