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

  def post_iframe_url(post_id, opts={})
    opts[:width] ||= 516
    opts[:height] ||= 315 
    host = AppConfig[:pod_uri].port ==80 ? AppConfig[:pod_uri].host : "#{AppConfig[:pod_uri].host}:#{AppConfig[:pod_uri].port}"
   "<iframe src='#{Rails.application.routes.url_helpers.post_url(post_id, :host => host)}' width='#{opts[:width]}px' height='#{opts[:height]}px' frameBorder='0'></iframe>".html_safe
  end
end
