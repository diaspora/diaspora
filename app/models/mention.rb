#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Mention < ActiveRecord::Base
  belongs_to :post
  belongs_to :person
  validates_presence_of :post
  validates_presence_of :person
end
