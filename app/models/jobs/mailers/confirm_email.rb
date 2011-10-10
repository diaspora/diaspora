#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  module Mailers
    class ConfirmEmail < Base
      @queue = :mail
      def self.perform(user_id)
        Notifier.confirm_email(user_id).deliver
      end
    end
  end
end
