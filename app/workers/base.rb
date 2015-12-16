#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class Base
    include Sidekiq::Worker
    sidekiq_options backtrace: (bt = AppConfig.environment.sidekiq.backtrace.get) && bt.to_i,
                    retry:  (rt = AppConfig.environment.sidekiq.retry.get) && rt.to_i

    include Diaspora::Logging

    # In the long term we need to eliminate the cause of these
    def suppress_annoying_errors(&block)
      yield
    rescue Diaspora::ContactRequiredUnlessRequest,
           Diaspora::RelayableObjectWithoutParent,
           # Friendica seems to provoke these
           Diaspora::AuthorXMLAuthorMismatch,
           # We received a private object to our public endpoint, again something
           # Friendica seems to provoke
           Diaspora::NonPublic,
           Diaspora::XMLNotParseable => e
      logger.warn "error on receive: #{e.class}"
    rescue ActiveRecord::RecordInvalid => e
      logger.warn "failed to save received object: #{e.record.errors.full_messages}"
      raise e unless %w(
        "already been taken"
        "is ignored by the post author"
      ).any? {|reason| e.message.include? reason }
    end
  end
end
