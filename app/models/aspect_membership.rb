#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectMembership < ActiveRecord::Base

  belongs_to :aspect
  belongs_to :contact
  has_one :user, :through => :contact
  has_one :person, :through => :contact

  before_destroy :ensure_membership
  
  
  def ensure_membership
    if self.contact.aspect_memberships.count == 1
      errors[:base] << I18n.t('shared.contact_list.cannot_remove')
      false
    else
      true
    end
  end
end
