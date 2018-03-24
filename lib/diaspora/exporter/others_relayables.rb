# frozen_string_literal: true

module Diaspora
  class Exporter
    # This class implements methods that allow to query relayables (comments, likes, participations,
    # poll_participations) of other people for posts of the given person.
    class OthersRelayables
      # @param person_id [Integer] Database id of a person for whom we want to request relayalbes
      def initialize(person_id)
        @person_id = person_id
      end

      # Comments of other people to the person's post
      # @return [Comment::ActiveRecord_Relation]
      def comments
        Comment
          .where.not(author_id: person_id)
          .joins("INNER JOIN posts ON (commentable_type = 'Post' AND posts.id = commentable_id)")
          .where("posts.author_id = ?", person_id)
      end

      # Likes of other people to the person's post
      # @return [Like::ActiveRecord_Relation]
      def likes
        Like
          .where.not(author_id: person_id)
          .joins("INNER JOIN posts ON (target_type = 'Post' AND posts.id = target_id)")
          .where("posts.author_id = ?", person_id)
      end

      # Poll participations of other people to the person's polls
      # @return [PollParticipation::ActiveRecord_Relation]
      def poll_participations
        PollParticipation
          .where.not(author_id: person_id).joins(:status_message)
          .where("posts.author_id = ?", person_id)
      end

      private

      attr_reader :person_id
    end
  end
end
