#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Contact < ActiveRecord::Base
  default_scope where(:pending => false)
  
  belongs_to :user
  validates_presence_of :user

  belongs_to :person
  validates_presence_of :person

  has_many :aspect_memberships, :dependent => :delete_all
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

  def contacts
    people = Person.arel_table
    incoming_aspects = Aspect.joins(:contacts).where(
      :user_id => self.person.owner_id,
      :contacts_visible => true,
      :contacts => {:person_id => self.user.person.id}).select('`aspects`.id')
    incoming_aspect_ids = incoming_aspects.map{|a| a.id}
    similar_contacts = Person.joins(:contacts => :aspect_memberships).where(
      :aspect_memberships => {:aspect_id => incoming_aspect_ids}).where(people[:id].not_eq(self.user.person.id)).select('DISTINCT `people`.*')
  end
  private
  def not_contact_for_self
    if person_id && person.owner == user
      errors[:base] << 'Cannot create self-contact'
    end
  end
end

