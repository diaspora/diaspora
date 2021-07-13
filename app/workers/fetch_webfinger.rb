# frozen_string_literal: true

#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class FetchWebfinger < Base
    sidekiq_options queue: :urgent

    def perform(account)
      person = Person.find_or_fetch_by_identifier(account)
      return if person.nil?
      return if person.pod&.blocked

      # also, schedule to fetch a few public posts from that person if its pod is not blocked
      Diaspora::Fetcher::Public.queue_for(person)
    end
  end
end
