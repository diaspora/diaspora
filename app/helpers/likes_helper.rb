#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module LikesHelper
  def likes_list(likes)
    links = likes.collect { |like| link_to "#{h(like.author.name.titlecase)}", local_or_remote_person_path(like.author) }
    links.join(", ").html_safe
  end

  def like_action(target, current_user=current_user)
    if target.instance_of?(Comment)
      if current_user.liked?(target)
        link_to t('shared.stream_element.unlike'), comment_like_path(target, current_user.like_for(target)), :method => :delete, :class => 'unlike', :remote => true
      else
        link_to t('shared.stream_element.like'), comment_likes_path(target, :positive => 'true'), :method => :post, :class => 'like', :remote => true
      end

    else

      if current_user.liked?(target)
        link_to t('shared.stream_element.unlike'), post_like_path(target, current_user.like_for(target)), :method => :delete, :class => 'unlike', :remote => true
      else
        link_to t('shared.stream_element.like'), post_likes_path(target, :positive => 'true'), :method => :post, :class => 'like', :remote => true
      end

    end
  end
end
