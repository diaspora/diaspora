class RemoveStartedSharingNotificationsWithoutContact < ActiveRecord::Migration
  class Notification < ActiveRecord::Base
  end

  def up
    Notification.where(type: "Notifications::StartedSharing", target_type: "Person")
                .joins("INNER JOIN people ON people.id = notifications.target_id")
                .joins("LEFT OUTER JOIN contacts ON contacts.person_id = people.id")
                .delete_all("contacts.id IS NULL")
  end
end
