#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/postzord/receiver/public')

module Jobs
  class ReceiveUnencryptedSalmon < Base
    extend Resque::Plugins::ExponentialBackoff
    
    @queue = :receive
    @backoff_strategy = [20.minutes,
                         1.day]

    def self.perform(xml)
      receiver = Postzord::Receiver::Public.new(xml)
      receiver.perform!
    end
  end
end
