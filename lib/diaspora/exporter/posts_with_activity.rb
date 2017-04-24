module Diaspora
  class Exporter
    # This class allows to query posts where a person made any activity (submitted comments,
    # likes, participations or poll participations).
    class PostsWithActivity
      # @param user [User] user who the activity belongs to (the one who liked, commented posts, etc)
      def initialize(user)
        @user = user
      end

      # Create a request of posts with activity
      # @return [Post::ActiveRecord_Relation]
      def query
        Post.from("(#{sql_union_all_activities}) AS posts")
      end

      private

      attr_reader :user

      def person
        user.person
      end

      def sql_union_all_activities
        all_activities.map(&:to_sql).join(" UNION ")
      end

      def all_activities
        [comments_activity, likes_activity, subscriptions, polls_activity, reshares_activity]
      end

      def likes_activity
        other_people_posts.liked_by(person)
      end

      def comments_activity
        other_people_posts.commented_by(person)
      end

      def subscriptions
        other_people_posts.subscribed_by(user)
      end

      def reshares_activity
        other_people_posts.reshared_by(person)
      end

      def polls_activity
        StatusMessage.where.not(author_id: person.id).joins(:poll_participations)
                     .where(poll_participations: {author_id: person.id})
      end

      def other_people_posts
        Post.where.not(author_id: person.id)
      end
    end
  end
end
