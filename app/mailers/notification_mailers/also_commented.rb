# frozen_string_literal: true

module NotificationMailers
  class AlsoCommented < NotificationMailers::Base
    attr_accessor :comment
    delegate :post, to: :comment, prefix: true

    def set_headers(comment_id)
      @comment = Comment.find_by_id(comment_id)

      if mail?
        @headers[:in_reply_to] = @headers[:references] = "<#{@comment.parent.guid}@#{AppConfig.pod_uri.host}>"
        if @comment.public?
          @headers[:subject] = "Re: #{@comment.comment_email_subject}"
        else
          @headers[:subject] = I18n.t("notifier.also_commented.limited_subject")
        end
      end
    end

    def mail?
      @recipient && @sender && @comment
    end
  end
end
