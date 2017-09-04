# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class PublishToHub < Base
    sidekiq_options queue: :medium

    def perform(sender_atom_url)
      Pubsubhubbub.new(AppConfig.environment.pubsub_server.get).publish(sender_atom_url)
    end
  end
end
