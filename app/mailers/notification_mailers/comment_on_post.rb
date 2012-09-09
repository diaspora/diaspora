module NotificationMailers
  class CommentOnPost < NotificationMailers::Base
    include ActionView::Helpers::TextHelper

    attr_accessor :comment

    def set_headers(comment_id)
      @comment = Comment.find(comment_id)

      @headers[:from] = "\"#{@comment.author_name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
      @headers[:subject] = truncate(@comment.comment_email_subject, :length => TRUNCATION_LEN)
      @headers[:subject] = "Re: #{@headers[:subject]}"
    end
  end
end
