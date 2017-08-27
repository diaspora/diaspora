# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectMembership < ApplicationRecord

  belongs_to :aspect
  belongs_to :contact
  has_one :user, :through => :contact
  has_one :person, :through => :contact

  before_destroy do
    if self.contact && self.contact.aspects.size == 1
      self.user.disconnect(self.contact)
    end
    true
  end

  def as_json(opts={})
    {
      :id => self.id,
      :person_id  => self.person.id,
      :contact_id => self.contact.id,
      :aspect_id  => self.aspect_id,
      :aspect_ids => self.contact.aspects.map{|a| a.id}
    }
  end
end
