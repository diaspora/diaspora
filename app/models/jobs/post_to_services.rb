#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class PostToServices
    extend ResqueJobLogging
    @queue = :http_service
    def self.perform(user_id, post_id, url)
      user = User.find_by_id(user_id)
      post = Post.find_by_id(post_id)
      user.services.each do |s|
        s.post(post, url)
      end
    end
  end
end
