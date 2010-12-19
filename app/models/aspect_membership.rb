#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectMembership < ActiveRecord::Base

  belongs_to :aspect
  belongs_to :person
  validates_presence_of :person
  validates_presence_of :aspect
  has_one :user, :through => :aspect

  validate :not_contact_for_self

  def dispatch_request
    request = self.generate_request
    self.user.push_to_people(request, [self.person])
    request
  end

  def generate_request
    Request.new(:from => self.user, :to => self.person)
  end

  private
  def not_contact_for_self
    if person.owner == user
      errors[:base] << 'Cannot create self-contact'
    end
  end
end
