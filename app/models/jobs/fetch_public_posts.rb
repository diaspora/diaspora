#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class FetchPublicPosts < Base
    @queue = :http_service

    def self.perform(diaspora_id)
      require Rails.root.join('lib','diaspora','fetcher','public')

      PublicFetcher.new.fetch!(diaspora_id)
    end
  end
end
