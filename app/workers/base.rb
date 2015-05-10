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
           Diaspora::RelayableObjectWithoutParent,
           # Friendica seems to provoke these
           Diaspora::AuthorXMLAuthorMismatch,
           # We received a private object to our public endpoint, again something
           # Friendica seems to provoke
           Diaspora::NonPublic => e
      Rails.logger.info("error on receive: #{e.class}")
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.info("failed to save received object: #{e.record.errors.full_messages}")
      raise e unless %w(
        "already been taken"
        "is ignored by the post author"
      ).any? {|reason| e.message.include? reason }
    rescue ActiveRecord::RecordNotUnique => e
      Rails.logger.info("failed to save received object: #{e.message}")
      raise e unless %w(
        index_comments_on_guid
        index_likes_on_guid
        index_posts_on_guid
        "duplicate key in table 'comments'"
        "duplicate key in table 'likes'"
        "duplicate key in table 'posts'"
      ).any? {|index| e.message.include? index }
    end
  end
end
