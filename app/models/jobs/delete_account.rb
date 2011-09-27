#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class DeleteAccount < Base
    @queue = :delete_account
    def self.perform(user_id)
      user = User.find(user_id)
      user.remove_all_traces
      user.destroy
    end
  end
end
