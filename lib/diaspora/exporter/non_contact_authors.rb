module Diaspora
  class Exporter
    # This class is capable of quering a list of people from authors of given posts that are non-contacts of a given
    # user.
    class NonContactAuthors
      # @param posts [Post::ActiveRecord_Relation] posts that we fetch authors from to make authors list
      # @param user [User] a user we fetch a contact list from
      def initialize(posts, user)
        @posts = posts
        @user = user
      end

      # Create a request of non-contact authors of the posts for the user
      # @return [Post::ActiveRecord_Relation]
      def query
        Person.where(id: non_contact_authors_ids)
      end

      private

      def non_contact_authors_ids
        posts_authors_ids - contacts_ids
      end

      def posts_authors_ids
        posts.pluck(:author_id).uniq
      end

      def contacts_ids
        user.contacts.pluck(:person_id)
      end

      attr_reader :posts, :user
    end
  end
end
