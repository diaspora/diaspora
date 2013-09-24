#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class Base
    include Sidekiq::Worker
    sidekiq_options backtrace: (bt = AppConfig.environment.sidekiq.backtrace.get) && bt.to_i,
                    retry:  (rt = AppConfig.environment.sidekiq.retry.get) && rt.to_i

    # In the long term we need to eliminate the cause of these
    def suppress_annoying_errors(&block)
      yield
    rescue Diaspora::ContactRequiredUnlessRequest,
           Diaspora::RelayableObjectWithoutParent => e
      Rails.logger.info("error on receive: #{e.class}")
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.info("failed to save received object: #{e.record.errors.full_messages}")
      raise e unless e.message.match(/already been taken/)
    end
  end
end
