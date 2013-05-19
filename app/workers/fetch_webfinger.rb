#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class FetchWebfinger < Base
    sidekiq_options queue: :socket_webfinger

    def perform(account)
      person = Webfinger.new(account).fetch

      # also, schedule to fetch a few public posts from that person
      Workers::FetchPublicPosts.perform_async(person.diaspora_handle) unless person.nil?
    end
  end
end
