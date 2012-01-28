#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


require File.join(Rails.root, 'lib/postzord/receiver/private')
module Jobs
  class ReceiveEncryptedSalmon < Base
    @queue = :receive_salmon

    def self.perform(user_id, xml)
      suppress_annoying_errors do
        user = User.find(user_id)
        zord = Postzord::Receiver::Private.new(user, :salmon_xml => xml)
        zord.perform!
      end
    end
  end
end

