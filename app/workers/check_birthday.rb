# frozen_string_literal: true

module Workers
  class CheckBirthday < Base
    sidekiq_options queue: :low

    def perform
      profiles = Profile
                 .where("EXTRACT(MONTH FROM birthday) = ?", Time.zone.today.month)
                 .where("EXTRACT(DAY FROM birthday) = ?", Time.zone.today.day)
      profiles.each do |profile|
        profile.person.contacts.where(sharing: true, receiving: true).each do |contact|
          Notifications::ContactsBirthday.notify(contact, [])
        end
      end
    end
  end
end
