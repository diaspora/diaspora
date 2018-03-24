# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class ExportUser < Base
    sidekiq_options queue: :low

    include Diaspora::Logging

    def perform(user_id)
      if currently_running_exports >= AppConfig.settings.export_concurrency.to_i
        logger.info "Already the maximum number of parallel user exports running, " \
                    "scheduling export for User:#{user_id} in 5 minutes."
        self.class.perform_in(5.minutes + rand(30), user_id)
      else
        export_user(user_id)
      end
    end

    private

    def export_user(user_id)
      @user = User.find(user_id)
      @user.perform_export!

      if @user.reload.export.present?
        ExportMailer.export_complete_for(@user).deliver_now
      else
        ExportMailer.export_failure_for(@user).deliver_now
      end
    end

    def currently_running_exports
      return 0 if AppConfig.environment.single_process_mode?
      Sidekiq::Workers.new.count do |process_id, thread_id, work|
        !(Process.pid.to_s == process_id.split(":")[1] && Thread.current.object_id.to_s(36) == thread_id) &&
          work["payload"]["class"] == self.class.to_s
      end
    end
  end
end
