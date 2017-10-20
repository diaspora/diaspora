# frozen_string_literal: true

module NotificationMailers
  class CommentOnPost < NotificationMailers::Base
    attr_accessor :comment

    def set_headers(comment_id)
      @comment = Comment.find(comment_id)

      @headers[:in_reply_to] = @headers[:references] = "<#{@comment.parent.guid}@#{AppConfig.pod_uri.host}>"
      if @comment.public?
        @headers[:subject] = "Re: #{@comment.comment_email_subject}"
      else
        @headers[:subject] = I18n.t("notifier.comment_on_post.limited_subject")
      end
    end
  end
end
