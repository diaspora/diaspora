#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class PublishToHub < Base
    sidekiq_options queue: :http_service

    def perform(sender_public_url)
      atom_url = sender_public_url + '.atom'
      Pubsubhubbub.new(AppConfig.environment.pubsub_server.get).publish(atom_url)
    end
  end
end
