# frozen_string_literal: true

module Mail
  class LikedWorker < NotifierBaseWorker
    def perform(*args)
      super
    rescue ActiveRecord::RecordNotFound => e
      logger.warn("failed to send liked notification mail: #{e.message}")
      raise e unless e.message.start_with?("Couldn't find Like with")
    end
  end
end
