module Api
  module V0
    class StreamsController < Api::V0::BaseController

      before_action do
        require_access_token %w(read)
      end

      def aspects
        aspect_ids = (params[:a_ids] || [])
        @stream = Stream::Aspect.new(current_user, aspect_ids, max_time: max_time)
        stream_responder
      end

      def public
        stream_responder(Stream::Public)
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

      def mentioned
        stream_responder(Stream::Mention)
      end

      def followed_tags
        stream_responder(Stream::FollowedTag)
      end

      private

      def stream_responder(stream_klass=nil)

        if stream_klass.present?
          @stream ||= stream_klass.new(current_user, max_time: max_time)
        end

        render json: @stream.stream_posts.map {|p| LastThreeCommentsDecorator.new(PostPresenter.new(p, current_user))}
      end
    end
  end
end
