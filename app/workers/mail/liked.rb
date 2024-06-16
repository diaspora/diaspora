# frozen_string_literal: true

module Workers
  module Mail
    class Liked < NotifierBase
      def perform(*args)
        super
      rescue ActiveRecord::RecordNotFound => e
        logger.warn("failed to send liked notification mail: #{e.message}")
        raise e unless e.message.start_with?("Couldn't find Like with")
      end
    end
  end
end
