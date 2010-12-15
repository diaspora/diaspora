#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


class Service
  include MongoMapper::Document
  include ActionView::Helpers::TextHelper
 
  belongs_to :user

  key :provider, String
  key :uid, String
  key :access_token, String
  key :access_secret, String
  key :nickname, String
  timestamps!

  def public_message(post, length, url = "")
    url = "" if post.respond_to?(:photos) && post.photos.count == 0
    space_for_url = url.blank? ? 0 : (url.length + 1)
    truncated = truncate(post.message, :length => (length - space_for_url))
    truncated = "#{truncated} #{url}" unless url.blank?
    return truncated
  end
end
require File.join(Rails.root, 'app/models/services/facebook')
require File.join(Rails.root, 'app/models/services/twitter')
require File.join(Rails.root, 'app/models/services/identica')
