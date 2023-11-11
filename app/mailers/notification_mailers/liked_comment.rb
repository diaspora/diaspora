# frozen_string_literal: true

module NotificationMailers
  class LikedComment < NotificationMailers::Base
    attr_accessor :like

    delegate :target, to: :like, prefix: true

    def set_headers(like_id) # rubocop:disable Naming/AccessorMethodName
      @like = Like.find(like_id)

      @headers[:subject] = I18n.t("notifier.liked_comment.liked", name: @sender.name)
      @headers[:in_reply_to] = @headers[:references] = "<#{@like.parent.commentable.guid}@#{AppConfig.pod_uri.host}>"
    end
  end
end
