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
end
