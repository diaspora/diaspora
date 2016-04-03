module Workers
  class ReceiveBase < Base
    sidekiq_options queue: :receive

    include Diaspora::Logging

    # don't retry for errors that will fail again
    def filter_errors_for_retry
      yield
    rescue DiasporaFederation::Entity::ValidationError,
           DiasporaFederation::Entity::InvalidRootNode,
           DiasporaFederation::Entity::InvalidEntityName,
           DiasporaFederation::Entity::UnknownEntity,
           DiasporaFederation::Entities::Relayable::SignatureVerificationFailed,
           DiasporaFederation::Federation::Receiver::InvalidSender,
           DiasporaFederation::Federation::Receiver::NotPublic,
           DiasporaFederation::Salmon::SenderKeyNotFound,
           DiasporaFederation::Salmon::InvalidEnvelope,
           DiasporaFederation::Salmon::InvalidSignature,
           DiasporaFederation::Salmon::InvalidAlgorithm,
           DiasporaFederation::Salmon::InvalidEncoding,
           # TODO: deprecated
           DiasporaFederation::Salmon::MissingMagicEnvelope,
           DiasporaFederation::Salmon::MissingAuthor,
           DiasporaFederation::Salmon::MissingHeader,
           DiasporaFederation::Salmon::InvalidHeader => e
      logger.warn "don't retry for error: #{e.class}"
    rescue ActiveRecord::RecordInvalid => e
      logger.warn "failed to save received object: #{e.record.errors.full_messages}"
      raise e unless [
        "already been taken",
        "is ignored by the post author"
      ].any? {|reason| e.message.include? reason }
    end
  end
end
