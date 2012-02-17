#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/postzord/receiver/public')

module Jobs
  class ReceiveUnencryptedSalmon < Base
    @queue = :receive

    def self.perform(xml)
      begin
        receiver = Postzord::Receiver::Public.new(xml)
        receiver.perform!
      rescue Exception => e
        FEDERATION_LOGGER.info(e.message)
        raise e
      end
    end
  end
end
