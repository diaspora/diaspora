# frozen_string_literal: true

module Workers
  class ReceiveBase < Base
    sidekiq_options queue: :urgent

    include Diaspora::Logging

    # don't retry for errors that will fail again
    def filter_errors_for_retry
      yield
    rescue DiasporaFederation::Entity::ValidationError,
           DiasporaFederation::Parsers::BaseParser::InvalidRootNode,
           DiasporaFederation::Entity::InvalidEntityName,
           DiasporaFederation::Entity::UnknownEntity,
           DiasporaFederation::Entities::Signable::PublicKeyNotFound,
           DiasporaFederation::Entities::Signable::SignatureVerificationFailed,
           DiasporaFederation::Entities::Participation::ParentNotLocal,
           DiasporaFederation::Federation::Receiver::InvalidSender,
           DiasporaFederation::Federation::Receiver::NotPublic,
           DiasporaFederation::Salmon::SenderKeyNotFound,
           DiasporaFederation::Salmon::InvalidEnvelope,
           DiasporaFederation::Salmon::InvalidSignature,
           DiasporaFederation::Salmon::InvalidDataType,
           DiasporaFederation::Salmon::InvalidAlgorithm,
           DiasporaFederation::Salmon::InvalidEncoding,
           Diaspora::Federation::AuthorIgnored,
           Diaspora::Federation::InvalidAuthor,
           Diaspora::Federation::PodBlocked,
           Diaspora::Federation::RecipientClosed => e
      logger.warn "don't retry for error: #{e.class}"
    end
  end
end
