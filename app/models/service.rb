#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Service
  include MongoMapper::Document

  belongs_to :user

  key :provider, String
  key :uid, String
  key :access_token, String
  key :access_secret, String
  key :nickname, String
  timestamps!

  def public_message(length, url = "")
    space_for_url = url.blank? ? 0 : (url.length + 1)
    truncated = truncate(self.message, :length => (length - space_for_url))
    truncated = "#{truncated} #{url}" unless url.blank?
    return truncated
  end
end
