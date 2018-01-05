# frozen_string_literal: true

module Workers
  class CleanupOldExports < Base
    sidekiq_options queue: :low

    def perform
      User.where("exported_at < ?", 14.days.ago).each do |user|
        user.remove_export = true
        user.exported_at = nil
        user.save
      end

      User.where("exported_photos_at < ?", 14.days.ago).each do |user|
        user.remove_exported_photos_file = true
        user.exported_photos_at = nil
        user.save
      end
    end
  end
end
