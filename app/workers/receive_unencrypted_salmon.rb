#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class ReceiveUnencryptedSalmon < Base
    sidekiq_options queue: :urgent

    def perform(xml)
      suppress_annoying_errors do
        receiver = Postzord::Receiver::Public.new(xml)
        receiver.perform!
      end
    end
  end
end
