# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Workers
  class ExportPhotos < Base
    sidekiq_options queue: :low

    def perform(user_id)
      @user = User.find(user_id)
      @user.perform_export_photos!

      if @user.reload.exported_photos_file.present?
        ExportMailer.export_photos_complete_for(@user)
      else
        ExportMailer.export_photos_failure_for(@user)
      end
    end
  end
end
