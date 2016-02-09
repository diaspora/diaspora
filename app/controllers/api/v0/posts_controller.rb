module Api
  module V0
    class PostsController < Api::V0::BaseController
      before_action only: %i(show get_related_resources show_relationship) do
        require_access_token %w(read)
      end

      before_action only: :create do
        require_access_token %w(read write)
      end

      def get_related_resources
        params[:custom_fetch_proc] = fetch_posts_from_person
        super
      end

      def context
        aspect_ids = params[:data][:attributes].delete(:aspect_ids) if params[:action] == "create"
        {current_user: current_user, params: params, aspect_ids: aspect_ids}
      end

      private

      def fetch_posts_from_person
        proc do |source_resource|
          person = source_resource._model
          posts = current_user.posts_from(person)
          posts.map {|post| Api::V0::PostResource.new(post, context) }
        end
      end
    end
  end
end
