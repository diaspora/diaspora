#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
module Jobs
  class PostToService < Base
    @queue = :http_service

    def self.perform(service_id, post_id, url)
      service = Service.find_by_id(service_id)
      post = Post.find_by_id(post_id)
      service.post(post, url)
    end
  end
end
