#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


require File.join(Rails.root, 'lib/postzord/receiver')
module Jobs
  class ReceiveSalmon
    extend ResqueJobLogging
    @queue = :receive_salmon
    def self.perform(user_id, xml)
      user = User.find(user_id)
      zord = Postzord::Receiver.new(user, :salmon_xml => xml)
      zord.perform
    end
  end
end
