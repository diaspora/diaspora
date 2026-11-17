# frozen_string_literal: true

class CheckBirthdayWorker < BaseWorker
  sidekiq_options queue: :low

  def perform
    profiles = Profile
               .where("EXTRACT(MONTH FROM birthday) = ?", Time.zone.today.month)
               .where("EXTRACT(DAY FROM birthday) = ?", Time.zone.today.day)
    profiles.find_each do |profile|
      profile.person.contacts.where(sharing: true, receiving: true).find_each do |contact|
        Notifications::ContactsBirthday.notify(contact, [])
      end
    end
  end
end
