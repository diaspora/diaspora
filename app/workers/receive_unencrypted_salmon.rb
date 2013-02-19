#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class ReceiveUnencryptedSalmon < Base
    sidekiq_options queue: :receive

    def perform(xml)
      suppress_annoying_errors do
        begin
          receiver = Postzord::Receiver::Public.new(xml)
          receiver.perform!
        rescue => e
          FEDERATION_LOGGER.info(e.message)
          raise e
        end
      end
    end
  end
end
