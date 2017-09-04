# frozen_string_literal: true

#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class FetchPublicPosts < Base
    sidekiq_options queue: :medium

    def perform(diaspora_id)
      Diaspora::Fetcher::Public.new.fetch!(diaspora_id)
    end
  end
end
