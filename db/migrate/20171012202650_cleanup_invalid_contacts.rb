# frozen_string_literal: true

class CleanupInvalidContacts < ActiveRecord::Migration[5.1]
  class Contact < ApplicationRecord
    belongs_to :user
    belongs_to :person

    has_many :aspect_memberships, dependent: :delete_all

    before_destroy :destroy_notifications

    def destroy_notifications
      Notification.where(
        target_type:  "Person",
        target_id:    person_id,
        recipient_id: user_id,
        type:         "Notifications::StartedSharing"
      ).destroy_all
    end
  end

  class User < ApplicationRecord
  end

  class Person < ApplicationRecord
    belongs_to :owner, class_name: "User", optional: true
  end

  class Notification < ApplicationRecord
    self.inheritance_column = nil
    has_many :notification_actors, dependent: :delete_all
  end

  class NotificationActor < ApplicationRecord
  end

  class AspectMembership < ApplicationRecord
  end

  def up
    Contact.left_outer_joins(:user).where("users.id is NULL").destroy_all
    Contact.left_outer_joins(person: :owner).where("people.owner_id is NOT NULL").where("users.id is NULL").destroy_all
  end
end
