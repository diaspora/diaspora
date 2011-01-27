#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectMembership < ActiveRecord::Base

  belongs_to :aspect
  belongs_to :contact
  has_one :user, :through => :contact
  has_one :person, :through => :contact

end
