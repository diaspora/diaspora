#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ShortUrlExpansion < ActiveRecord::Base
  validates :url_short,    :presence => true, :uniqueness => true
  validates :url_expanded, :presence => true
end
