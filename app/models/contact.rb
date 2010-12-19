#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Contact < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user

  belongs_to :person
  validates_presence_of :person

  has_many :aspect_memberships
  has_many :aspects, :through => :aspect_memberships
  validate :not_contact_for_self
  def dispatch_request
    request = self.generate_request
    self.user.push_to_people(request, [self.person])
    request
  end

  def generate_request
    Request.new(:sender => self.user, :recipient => self.person)
  end

  private
  def not_contact_for_self
    if person.owner == user
      errors[:base] << 'Cannot create self-contact'
    end
  end
end

