#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module LikesHelper
  def likes_list(likes)
    links = likes.collect { |like| link_to "#{h(like.author.name.titlecase)}", person_path(like.author) }
    links.join(", ").html_safe
  end

  def like_action(post, current_user=current_user)
    if current_user.liked?(post)
      link_to t('shared.stream_element.unlike'), post_like_path(post, current_user.like_for(post)), :method => :delete, :class => 'unlike', :remote => true
    else
      link_to t('shared.stream_element.like'), post_likes_path(post, :positive => 'true'), :method => :post, :class => 'like', :remote => true
    end
  end
end
