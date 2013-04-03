#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Service < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include MarkdownifyHelper
  
  belongs_to :user
  validates_uniqueness_of :uid, :scope => :type

  def self.titles(service_strings)
    service_strings.map{|s| "Services::#{s.titleize}"}
  end

  def public_message(post, length, url = "", always_include_post_url = true, markdown = false)
    Rails.logger.info("Posting out to #{self.class}")
    if ! markdown
      post_text = strip_markdown(post.text(:plain_text => true))
    else
      post_text = post.text(:plain_text => true)
    end
    if post_text.length <= length && ! always_include_post_url
        # include url to diaspora when posting only when it exceeds length
        url = ""
        space_for_url = 0
    else
        url = " " + Rails.application.routes.url_helpers.short_post_url(post, :protocol => AppConfig.pod_uri.scheme, :host => AppConfig.pod_uri.authority)
        space_for_url = 21 + 1
    end
    truncated = truncate(post_text, :length => (length - space_for_url))
    truncated = "#{truncated}#{url}"
    return truncated
  end

  def profile_photo_url
    nil
  end

end
require 'services/facebook'
require 'services/twitter'
