module NotificationMailers
  class AlsoCommented < NotificationMailers::Base
    attr_accessor :comment
    delegate :post, to: :comment, prefix: true

    def set_headers(comment_id)
      @comment = Comment.find_by_id(comment_id)

      if mail?
        @headers[:from] = "\"#{@comment.author_name} (diaspora*)\" <#{AppConfig.mail.sender_address}>"
        @headers[:subject] = "Re: #{@comment.comment_email_subject}"
      end
    end

    def mail?
      @recipient && @sender && @comment
    end
  end
end
