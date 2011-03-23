#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Service < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  belongs_to :user
  has_many :service_users

  def public_message(post, length, url = "")
    url = "" if post.respond_to?(:photos) && post.photos.count == 0
    space_for_url = url.blank? ? 0 : (url.length + 1)
    truncated = truncate(post.text(:plain_text => true), :length => (length - space_for_url))
    truncated = "#{truncated} #{url}" unless url.blank?
    return truncated
  end
end
require File.join(Rails.root, 'app/models/services/facebook')
require File.join(Rails.root, 'app/models/services/twitter')
