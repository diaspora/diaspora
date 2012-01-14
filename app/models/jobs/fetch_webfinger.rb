#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class FetchWebfinger < Base
    @queue = :socket_webfinger

    def self.perform(account)
      Webfinger.new(account).fetch
    end
  end
end
