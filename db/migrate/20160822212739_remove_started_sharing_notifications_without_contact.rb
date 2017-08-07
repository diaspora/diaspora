class RemoveStartedSharingNotificationsWithoutContact < ActiveRecord::Migration[4.2]
  class Notification < ApplicationRecord
  end

  def up
    Notification.where(type: "Notifications::StartedSharing", target_type: "Person")
                .joins("INNER JOIN people ON people.id = notifications.target_id")
                .joins("LEFT OUTER JOIN contacts ON contacts.person_id = people.id " \
                       "AND contacts.user_id = notifications.recipient_id")
                .where("contacts.id IS NULL")
                .delete_all
  end
end
