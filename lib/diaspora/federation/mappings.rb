# frozen_string_literal: true

module Diaspora
  module Federation
    module Mappings
      # rubocop:disable Metrics/CyclomaticComplexity

      # used in Diaspora::Federation::Receive
      def self.receiver_for(federation_entity)
        case federation_entity
        when DiasporaFederation::Entities::AccountMigration  then :account_migration
        when DiasporaFederation::Entities::Comment           then :comment
        when DiasporaFederation::Entities::Contact           then :contact
        when DiasporaFederation::Entities::Conversation      then :conversation
        when DiasporaFederation::Entities::Like              then :like
        when DiasporaFederation::Entities::Message           then :message
        when DiasporaFederation::Entities::Participation     then :participation
        when DiasporaFederation::Entities::Photo             then :photo
        when DiasporaFederation::Entities::PollParticipation then :poll_participation
        when DiasporaFederation::Entities::Profile           then :profile
        when DiasporaFederation::Entities::Reshare           then :reshare
        when DiasporaFederation::Entities::StatusMessage     then :status_message
        else not_found(federation_entity.class)
        end
      end

      # used in Diaspora::Federation::Entities
      def self.builder_for(diaspora_entity)
        case diaspora_entity
        when AccountMigration  then :account_migration
        when AccountDeletion   then :account_deletion
        when Comment           then :comment
        when Contact           then :contact
        when Conversation      then :conversation
        when Like              then :like
        when Message           then :message
        when Participation     then :participation
        when Photo             then :photo
        when PollParticipation then :poll_participation
        when Profile           then :profile
        when Reshare           then :reshare
        when Retraction        then :retraction
        when ContactRetraction then :retraction
        when StatusMessage     then :status_message
        else not_found(diaspora_entity.class)
        end
      end

      def self.model_class_for(entity_name)
        case entity_name
        when "Comment"           then Comment
        when "Conversation"      then Conversation
        when "Like"              then Like
        when "Participation"     then Participation
        when "PollParticipation" then PollParticipation
        when "Photo"             then Photo
        when "Poll"              then Poll
        when "Post"              then Post
        when "Person"            then Person # TODO: deprecated
        when "Reshare"           then Post
        when "StatusMessage"     then Post
        else not_found(entity_name)
        end
      end

      def self.entity_name_for(model)
        case model
        when Comment           then "Comment"
        when Like              then "Like"
        when Participation     then "Participation"
        when PollParticipation then "PollParticipation"
        when Photo             then "Photo"
        when Post              then "Post"
        else not_found(model.class)
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      private_class_method def self.not_found(key)
        raise DiasporaFederation::Entity::UnknownEntity, "unknown entity: #{key}"
      end
    end
  end
end
