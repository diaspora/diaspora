#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Workers
  class ReceiveEncryptedSalmon < Base
    sidekiq_options queue: :receive_salmon

    def perform(user_id, xml)
      suppress_annoying_errors do
        user = User.find(user_id)
        zord = Postzord::Receiver::Private.new(user, :salmon_xml => xml)
        zord.perform!
      end
    end
  end
end

