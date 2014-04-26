module NotificationMailers
  class CommentOnPost < NotificationMailers::Base
    attr_accessor :comment

    def set_headers(comment_id)
      @comment = Comment.find(comment_id)

      @headers[:from] = "\"#{@comment.author_name} (diaspora*)\" <#{AppConfig.mail.sender_address}>"
      @headers[:subject] = "Re: #{@comment.comment_email_subject}"
    end
  end
end
