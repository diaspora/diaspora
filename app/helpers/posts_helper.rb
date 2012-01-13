#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PostsHelper
  def post_page_title(post)
    if post.is_a?(Photo)
      I18n.t "posts.show.photos_by", :count => 1, :author => post.status_message.author.name
    elsif post.is_a?(Reshare)
      I18n.t "posts.show.reshare_by", :author => post.author.name
    else
      if post.text.present?
        truncate(post.text(:plain_text => true), :length => 20)
      elsif post.respond_to?(:photos) && post.photos.present?
        I18n.t "posts.show.photos_by", :count => post.photos.size, :author => post.author.name
      end
    end
  end
end
