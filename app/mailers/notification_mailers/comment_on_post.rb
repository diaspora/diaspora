module NotificationMailers
  class CommentOnPost < NotificationMailers::Base
    include ActionView::Helpers::TextHelper
    include MarkdownifyHelper

    attr_accessor :comment

    def set_headers(comment_id)
      @comment = Comment.find(comment_id)

      @headers[:from] = "\"#{@comment.author_name} (Diaspora*)\" <#{AppConfig.mail.sender_address}>"
      @headers[:subject] = truncate(strip_markdown(@comment.comment_email_subject.squish), :length => TRUNCATION_LEN)
      @headers[:subject] = "Re: #{@headers[:subject]}"
    end
  end
end
