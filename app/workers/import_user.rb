# frozen_string_literal: true

module Workers
  class ImportUser < ArchiveBase
    private

    def perform_archive_job(user_id)
      user = User.find(user_id)
      ImportService.new.import_by_user(user)
    end
  end
end
