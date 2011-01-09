#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class PublishToHub
    extend ResqueJobLogging
    @queue = :http_service

    def self.perform(sender_public_url)
      PubSubHubbub.new(AppConfig[:pubsub_server]).publish(sender_public_url)
    end
  end
end
