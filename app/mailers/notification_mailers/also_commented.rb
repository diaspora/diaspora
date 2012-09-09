module NotificationMailers
  class AlsoCommented < NotificationMailers::Base
    include ActionView::Helpers::TextHelper

    attr_accessor :comment
    delegate :post, to: :comment, prefix: true

    def set_headers(comment_id)
      @comment = Comment.find_by_id(comment_id)

      if mail?
        @headers[:from] = "\"#{@comment.author_name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
        @headers[:subject] = truncate(@comment.comment_email_subject, :length => TRUNCATION_LEN)
        @headers[:subject] = "Re: #{@headers[:subject]}"
      end
    end

    def mail?
      @recipient && @sender && @comment
    end
  end
end
