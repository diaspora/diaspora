# frozen_string_literal: true

module Api
  module V1
    class StreamsController < Api::V1::BaseController
      before_action do
        require_access_token %w[read]
      end

      def aspects
        aspect_ids = params.has_key?(:aspect_ids) ? JSON.parse(params[:aspect_ids]) : []
        @stream = Stream::Aspect.new(current_user, aspect_ids, max_time: max_time)
        stream_responder
      end

      def activity
        stream_responder(Stream::Activity)
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

      def stream_responder(stream_klass=nil)
        @stream = stream_klass.present? ? stream_klass.new(current_user, max_time: max_time) : @stream

        render json: @stream.stream_posts.map {|p| PostPresenter.new(p, current_user).as_api_response }
      end
    end
  end
end
