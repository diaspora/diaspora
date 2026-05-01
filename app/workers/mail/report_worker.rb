# frozen_string_literal: true

module Mail
  class ReportWorker < ::BaseWorker
    sidekiq_options queue: :low

    def perform(report_id)
      ReportMailer.new_report(report_id).each(&:deliver_now)
    end
  end
end
