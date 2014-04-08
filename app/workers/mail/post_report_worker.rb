module Workers
  module Mail
    class PostReportWorker < Base
      sidekiq_options queue: :mail

      def perform
        PostReportMailer.new_report
      end
    end
  end
end

