# frozen_string_literal: true

module Api
  module V1
    class SearchController < Api::V1::BaseController
      before_action do
        require_access_token %w[public:read]
      end

      rescue_from ActionController::ParameterMissing, RuntimeError do
        render_error 422, "Search request could not be processed"
      end

      def user_index
        user_page = index_pager(people_query).response
        user_page[:data] = user_page[:data].map {|p| PersonPresenter.new(p).as_api_json }
        render_paged_api_response user_page
      end

      def post_index
        posts_page = time_pager(posts_query, "posts.created_at", "created_at").response
        posts_page[:data] = posts_page[:data].map {|post| PostPresenter.new(post).as_api_response }
        render_paged_api_response posts_page
      end

      private

      def time_pager(query, query_time_field, data_time_field)
        Api::Paging::RestPaginatorBuilder.new(query, request).time_pager(params, query_time_field, data_time_field)
      end

      def people_query
        parameters = params.permit(:tag, :name_or_handle)
        raise RuntimeError if parameters.keys.length != 1

        if params.has_key?(:tag)
          Person.profile_tagged_with(params[:tag])
        else
          connected_only = !private_read?
          Person.search(
            params[:name_or_handle],
            current_user,
            only_contacts: connected_only,
            mutual:        connected_only
          )
        end
      end

      def posts_query
        if private_read?
          Stream::Tag.new(current_user, params.require(:tag)).posts
        else
          Stream::Tag.new(nil, params.require(:tag)).posts
        end
      end
    end
  end
end
