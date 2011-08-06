#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectVisibility < ActiveRecord::Base

  belongs_to :aspect
  validates_presence_of :aspect

  belongs_to :post
  validates_presence_of :post

end
