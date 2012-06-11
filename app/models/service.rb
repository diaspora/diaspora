#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Service < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  belongs_to :user
  validates_uniqueness_of :uid, :scope => :type

  def self.titles(service_strings)
    service_strings.map{|s| "Services::#{s.titleize}"}
  end

  def public_message(post, length, url = "")
    Rails.logger.info("Posting out to #{self.class}")
    url = Rails.application.routes.url_helpers.short_post_url(post, :protocol => AppConfig[:pod_uri].scheme, :host => AppConfig[:pod_uri].authority)
    space_for_url = 21 + 1
    truncated = truncate(post.text(:plain_text => true), :length => (length - space_for_url))
    truncated = "#{truncated} #{url}"
    return truncated
  end


  def profile_photo_url
    nil
  end

end
require Rails.root.join('app', 'models', 'services', 'facebook')
require Rails.root.join('app', 'models', 'services', 'twitter')
