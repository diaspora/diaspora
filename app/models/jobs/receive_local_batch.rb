#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class ReceiveLocalBatch < Base
    require File.join(Rails.root, 'lib/postzord/receiver')

    @queue = :receive
    def self.perform_delegate(author_id, post_id, recipient_user_ids)
    end
    def self.create_visibilities(post, recipient_user_ids)
      aspects = Aspect.where(:user_id => recipient_user_ids).joins(:contacts).where(:contacts => {:person_id => post.author_id}).select('aspects.id, aspects.user_id')
      aspects.each do |aspect|
        PostVisibility.create(:aspect_id => aspect.id, :post_id => post.id)
        post.socket_to_user(aspect.user_id, :aspect_ids => [aspect.id]) if post.respond_to? :socket_to_user
      end
    end
  end
end
