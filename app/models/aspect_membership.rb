#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectMembership < ActiveRecord::Base
  belongs_to :aspect
  belongs_to :contact
  has_one :user, through: :contact
  has_one :person, through: :contact

  before_destroy do
    if contact && contact.aspects.size == 1
      user.disconnect(contact)
    end
    true
  end

  def as_json(_opts = {})
    {
      id: id,
      person_id: person.id,
      contact_id: contact.id,
      aspect_id: aspect_id,
      aspect_ids: contact.aspects.map(&:id)
    }
  end
end
