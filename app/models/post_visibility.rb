#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostVisibility < ActiveRecord::Base
  default_scope where(:hidden => false)

  belongs_to :contact
  belongs_to :post
end
