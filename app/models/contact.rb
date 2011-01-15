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
  validates_uniqueness_of :person_id, :scope => :user_id

  def dispatch_request
    request = self.generate_request
    Postzord::Dispatch.new(self.user, request).post
    request
  end

  def generate_request
    Request.new(:sender => self.user.person,
                :recipient => self.person,
                :aspect => aspects.first)
  end

  private
  def not_contact_for_self
    if person_id && person.owner == user
      errors[:base] << 'Cannot create self-contact'
    end
  end
end

