# frozen_string_literal: true

module NotificationMailers
  class Liked < NotificationMailers::Base
    attr_accessor :like
    delegate :target, to: :like, prefix: true

    def set_headers(like_id)
      @like = Like.find(like_id)

      @headers[:subject] = I18n.t('notifier.liked.liked', :name => @sender.name)
      @headers[:in_reply_to] = @headers[:references] = "<#{@like.parent.guid}@#{AppConfig.pod_uri.host}>"
    end
  end
end
