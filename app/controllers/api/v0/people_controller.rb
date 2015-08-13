module Api
  module V0
    class PeopleController < Api::V0::BaseController
      before_action only: :show do
        require_access_token %w(openid)
      end

      before_action only: %i(show_relationship get_related_resource) do
        require_access_token %w(read)
      end

      def show_relationship
        params[:custom_fetch_proc] = fetch_post_relationships_from_person_resource
        super
      end

      def get_related_resource
        params[:custom_fetch_proc] = fetch_person_resource_from_source_resource
        super
      end

      private

      def fetch_post_relationships_from_person_resource
        proc do |person_resource|
          person = person_resource._model
          posts = current_user.posts_from(person)
          posts.map {|post| ["posts", post.id] }
        end
      end

      def fetch_person_resource_from_source_resource
        proc do |source_resource|
          person_resource = source_resource.author
          person_resource.tap do |person_resource|
            person_model = person_resource._model
            raise JSONAPI::Exceptions::RecordNotFound if person_model.nil?
            raise Diaspora::AccountClosed if person_model.closed_account?
          end
        end
      end
    end
  end
end
