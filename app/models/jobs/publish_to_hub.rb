#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class PublishToHub < Base
    @queue = :http_service

    def self.perform(sender_public_url)
      require Rails.root.join('lib', 'pubsubhubbub')
      atom_url = sender_public_url + '.atom'
      Pubsubhubbub.new(AppConfig[:pubsub_server]).publish(atom_url)
    end
  end
end
