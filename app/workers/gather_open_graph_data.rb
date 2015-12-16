#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

module Workers
  class GatherOpenGraphData < Base
    sidekiq_options queue: :http_service

    def perform(post_id, url, retry_count=1)
      post = Post.find(post_id)
      post.open_graph_cache = OpenGraphCache.find_or_create_by(url: url)
      post.save
    rescue ActiveRecord::RecordNotFound
      # User created a post and deleted it right afterwards before we
      # we had a chance to run the job.
      # On the other hand sometimes the job runs before the Post is
      # fully persisted. So we just reduce the amount of retries.
      GatherOpenGraphData.perform_in(1.minute, post_id, url, retry_count+1) unless retry_count > 3
    end
  end
end
