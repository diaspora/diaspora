module Diaspora
  module Federation
    module Mappings
      # used in Diaspora::Federation::Receive
      def self.receiver_for(federation_class)
        fetch_from(ENTITY_RECEIVERS, federation_class)
      end

      # used in Diaspora::Federation::Entities
      def self.builder_for(diaspora_class)
        fetch_from(ENTITY_BUILDERS, diaspora_class)
      end

      def self.model_class_for(entity_name)
        fetch_from(ENTITY_MODELS, entity_name)
      end

      def self.entity_name_for(model)
        fetch_from(ENTITY_NAMES, model.class.base_class)
      end

      private_class_method def self.fetch_from(mapping, key)
        mapping.fetch(key) { raise DiasporaFederation::Entity::UnknownEntity, "unknown entity: #{key}" }
      end

      ENTITY_RECEIVERS = {
        DiasporaFederation::Entities::Comment           => :comment,
        DiasporaFederation::Entities::Contact           => :contact,
        DiasporaFederation::Entities::Conversation      => :conversation,
        DiasporaFederation::Entities::Like              => :like,
        DiasporaFederation::Entities::Message           => :message,
        DiasporaFederation::Entities::Participation     => :participation,
        DiasporaFederation::Entities::Photo             => :photo,
        DiasporaFederation::Entities::PollParticipation => :poll_participation,
        DiasporaFederation::Entities::Profile           => :profile,
        DiasporaFederation::Entities::Reshare           => :reshare,
        DiasporaFederation::Entities::StatusMessage     => :status_message
      }.freeze

      ENTITY_BUILDERS = {
        AccountDeletion   => :account_deletion,
        Comment           => :comment,
        Contact           => :contact,
        Conversation      => :conversation,
        Like              => :like,
        Message           => :message,
        Participation     => :participation,
        Photo             => :photo,
        PollParticipation => :poll_participation,
        Profile           => :profile,
        Reshare           => :reshare,
        Retraction        => :build_retraction,
        StatusMessage     => :status_message
      }.freeze

      ENTITY_MODELS = {
        "Comment"           => Comment,
        "Conversation"      => Conversation,
        "Like"              => Like,
        "Participation"     => Participation,
        "PollParticipation" => PollParticipation,
        "Photo"             => Photo,
        "Poll"              => Poll,
        "Post"              => Post,
        # TODO: deprecated
        "Person"            => Person,
        "Reshare"           => Post,
        "StatusMessage"     => Post
      }.freeze

      ENTITY_NAMES = {
        Comment           => "Comment",
        Like              => "Like",
        Participation     => "Participation",
        PollParticipation => "PollParticipation",
        Photo             => "Photo",
        Post              => "Post"
      }.freeze
    end
  end
end
