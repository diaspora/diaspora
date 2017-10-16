# frozen_string_literal: true

class CleanupInvalidDiasporaIds < ActiveRecord::Migration[5.1]
  def up
    ids = Person.where("diaspora_handle LIKE '%@%/%'").ids
    return if ids.empty?

    AspectMembership.joins(:contact).where(contacts: {person_id: ids}).delete_all

    Person.where(id: ids).each do |person|
      destroy_notifications_for_person(person)
      person.destroy
    end
  end

  def destroy_notifications_for_person(person)
    Notification.joins(:notification_actors).where(notification_actors: {person_id: person.id}).each do |notification|
      if notification.notification_actors.count > 1
        notification.notification_actors.where(person_id: person.id).delete_all
      else
        notification.destroy
      end
    end
  end
end
