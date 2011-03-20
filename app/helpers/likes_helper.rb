#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module LikesHelper
  def likes_list likes
    links = likes.collect { |like| link_to "#{h(like.author.name.titlecase)}", person_path(like.author) }
    links.join(", ").html_safe
  end
end
