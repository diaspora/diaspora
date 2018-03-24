# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Mention < ApplicationRecord
  belongs_to :mentions_container, polymorphic: true
  belongs_to :person

  scope :local, -> {
    joins(:person).where.not(people: {owner_id: nil})
  }

  after_destroy :delete_notification

  def delete_notification
    Notification.where(target_type: self.class.name, target_id: id).destroy_all
  end
end
