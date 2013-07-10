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
      if post.text.present?
        if opts.has_key?(:length)
           truncate(post.text(:plain_text => true), :length => opts.fetch(:length))
        elsif /\A(?:  # Regexp to match a Markdown header present on first line :
              (?<setext_content>.{1,200}\n(?:={1,200}|-{1,200}))(?:\r?\n|$)           # Setext-style header
                  |                                                                   # or
              (?<atx_content>\#{1,6}\s.{1,200})(?:\r?\n|$)                            # Atx-style header
               )/x   =~  post.text(:plain_text => true)
          return setext_content unless setext_content.nil?
          return atx_content unless atx_content.nil?
        else
          truncate(post.text(:plain_text => true), :length => 20 )
        end
      elsif post.respond_to?(:photos) && post.photos.present?
        I18n.t "posts.show.photos_by", :count => post.photos.size, :author => post.author_name
      end
    end
  end

  def post_iframe_url(post_id, opts={})
    opts[:width] ||= 516
    opts[:height] ||= 315
    host = AppConfig.pod_uri.authority
   "<iframe src='#{Rails.application.routes.url_helpers.post_url(post_id, :host => host)}' width='#{opts[:width]}px' height='#{opts[:height]}px' frameBorder='0'></iframe>".html_safe
  end
end
