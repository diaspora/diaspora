module Workers
  module Mail
    class ReportWorker < Base
      sidekiq_options queue: :mail

      def perform(type, id)
        ReportMailer.new_report(type, id)
      end
    end
  end
end

