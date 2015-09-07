module Workers
  module Mail
    class ReportWorker < Base
      sidekiq_options queue: :mail

      def perform(type, id)
        ReportMailer.new_report(type, id).each(&:deliver_now)
      end
    end
  end
end
