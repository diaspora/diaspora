#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module LikesHelper
  def likes_list(likes)
    links = likes.collect { |like| link_to "#{h(like.author.name.titlecase)}", person_path(like.author) }
    links.join(", ").html_safe
  end

  def like_action(post)
    if current_user.liked?(post)
      link_to t('shared.stream_element.unlike'), like_path(:post_id => post.id, :id => 'xxx'), :method => :delete, :class => 'unlike', :remote => true
    else
      link_to t('shared.stream_element.like'), likes_path(:positive => 'true', :post_id => post.id ), :method => :post, :class => 'like', :remote => true
    end
  end
end
