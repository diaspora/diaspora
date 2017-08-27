# frozen_string_literal: true

#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PostsHelper
  def post_page_title(post, opts={})
    if post.is_a?(Photo)
      I18n.t "posts.show.photos_by", :count => 1, :author => post.status_message_author_name
    elsif post.is_a?(Reshare)
      I18n.t "posts.show.reshare_by", :author => post.author_name
    else
      if post.message.present?
        post.message.title opts
      elsif post.respond_to?(:photos) && post.photos.present?
        I18n.t "posts.show.photos_by", :count => post.photos.size, :author => post.author_name
      end
    end
  end

  def post_iframe_url(post_id, opts={})
    opts[:width] ||= 516
    opts[:height] ||= 315
    "<iframe src='#{AppConfig.url_to(Rails.application.routes.url_helpers.post_path(post_id))}' " \
      "width='#{opts[:width]}px' height='#{opts[:height]}px' frameBorder='0'></iframe>".html_safe
  end
end
