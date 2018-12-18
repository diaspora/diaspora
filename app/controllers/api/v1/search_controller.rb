# frozen_string_literal: true

module Api
  module V1
    class SearchController < Api::V1::BaseController
      before_action do
        require_access_token %w[public:read]
      end

      rescue_from ActionController::ParameterMissing, RuntimeError do
        render json: I18n.t("api.endpoint_errors.search.cant_process"), status: :unprocessable_entity
      end

      def user_index
        parameters = params.permit(:tag, :name_or_handle)
        raise RuntimeError if parameters.keys.length != 1
        people_query = if params.has_key?(:tag)
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
        user_page = index_pager(people_query).response
        user_page[:data] = user_page[:data].map {|p| PersonPresenter.new(p).as_api_json }
        render json: user_page
      end

      def post_index
        posts_query = if private_read?
                        Stream::Tag.new(current_user, params.require(:tag)).posts
                      else
                        Stream::Tag.new(nil, params.require(:tag)).posts
                      end
        posts_page = time_pager(posts_query, "posts.created_at", "created_at").response
        posts_page[:data] = posts_page[:data].map {|post| PostPresenter.new(post).as_api_response }
        render json: posts_page
      end

      private

      def time_pager(query, query_time_field, data_time_field)
        Api::Paging::RestPaginatorBuilder.new(query, request).time_pager(params, query_time_field, data_time_field)
      end
    end
  end
end
