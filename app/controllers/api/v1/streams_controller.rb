# frozen_string_literal: true

module Api
  module V1
    class StreamsController < Api::V1::BaseController
      before_action do
        require_access_token %w[public:read]
      end

      before_action only: %w[aspects] do
        require_access_token %w[contacts:read private:read]
      end

      before_action only: %w[followed_tags] do
        require_access_token %w[tags:read]
      end

      def aspects
        aspect_ids = params.has_key?(:aspect_ids) ? JSON.parse(params[:aspect_ids]) : []
        @stream = Stream::Aspect.new(current_user, aspect_ids, max_time: stream_max_time)
        stream_responder
      end

      def activity
        stream_responder(Stream::Activity, "posts.interacted_at", "interacted_at")
      end

      def multi
        stream_responder(Stream::Multi)
      end

      def commented
        stream_responder(Stream::Comments)
      end

      def liked
        stream_responder(Stream::Likes)
      end

      def mentions
        stream_responder(Stream::Mention)
      end

      def followed_tags
        stream_responder(Stream::FollowedTag)
      end

      private

      def stream_responder(stream_klass=nil, query_time_field="posts.created_at", data_time_field="created_at")
        @stream = stream_klass.present? ? stream_klass.new(current_user, max_time: stream_max_time) : @stream
        query = @stream.stream_posts
        query = query.where(public: true) unless private_read?
        posts_page = pager(query, query_time_field, data_time_field).response
        posts_page[:data] = posts_page[:data].map {|post| PostPresenter.new(post, current_user).as_api_response }
        posts_page[:links].delete(:previous)
        render_paged_api_response posts_page
      end

      def stream_max_time
        if params.has_key?("before")
          Time.iso8601(params["before"])
        else
          max_time
        end
      end

      def pager(query, query_time_field, data_time_field)
        Api::Paging::RestPaginatorBuilder.new(query, request, true, 15)
                                         .time_pager(params, query_time_field, data_time_field)
      end
    end
  end
end
