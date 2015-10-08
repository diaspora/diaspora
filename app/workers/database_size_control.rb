
module Workers
  class DatabaseSizeControl < Base
    include Sidetiq::Schedulable

    sidekiq_options queue: :maintenance

    recurrence { daily }

    def perform
      return unless AppConfig.settings.maintenance.database_size_control.enable?
      remove_signatures
    end

    def remove_signatures
      return unless AppConfig.settings.maintenance.database_size_control.remove_old_participations_after?
      remove_before_date = Time.zone.today -
        (AppConfig.settings.maintenance.database_size_control.remove_old_participations_after.to_i).days
      remove_like_sigs(remove_before_date)
      remove_participation_sigs(remove_before_date)
    end

    def remove_participation_sigs(remove_before_date)
      removals = Participation.where(
        "created_at < ? and (author_signature is not null or parent_author_signature is not null)",
        remove_before_date).update_all(
          author_signature: nil, parent_author_signature: nil
        )
      logger.info "DatabaseSizeControl: nullified #{removals} signatures from the participations table"
    end

    def remove_like_sigs(remove_before_date)
      removals = Like.where(
        "created_at < ? and (author_signature is not null or parent_author_signature is not null)",
        remove_before_date).update_all(
          author_signature: nil, parent_author_signature: nil
        )
      logger.info "DatabaseSizeControl: nullified #{removals} signatures from the likes table"
    end
  end
end
