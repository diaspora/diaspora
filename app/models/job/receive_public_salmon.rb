#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class ReceivePublicSalmon < Base
    require File.join(Rails.root, 'lib/postzord/receiver')

    @queue = :receive

    def self.perform(xml)
      receiver = Postzord::Receiver::Public.new(xml)
      receiver.perform!
    end
  end
end
