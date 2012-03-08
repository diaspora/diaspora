#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Service < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  belongs_to :user
  validates_uniqueness_of :uid, :scope => :type
  has_many :service_users, :dependent => :destroy

  def self.titles(service_strings)
    service_strings.map{|s| "Services::#{s.titleize}"}
  end

  def public_message(post, length, url = "")
    Rails.logger.info("Posting out to #{self.class}")
    url = "" if post.respond_to?(:photos) && post.photos.count == 0
    space_for_url = url.blank? ? 0 : (url.length + 1)
    truncated = truncate(post.text(:plain_text => true), :length => (length - space_for_url))
    truncated = "#{truncated} #{url}" unless url.blank?
    return truncated
  end


  def profile_photo_url
    nil
  end

end
require File.join(Rails.root, 'app/models/services/facebook')
require File.join(Rails.root, 'app/models/services/twitter')
