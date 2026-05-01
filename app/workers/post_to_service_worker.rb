# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class PostToServiceWorker < BaseWorker
  sidekiq_options queue: :medium

  def perform(service_id, post_id, url)
    service = Service.find_by(id: service_id)
    post = Post.find_by(id: post_id)
    service.post(post, url)
  end
end
