#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module NotificationMailers
  class AlsoCommented < NotificationMailers::Base
    include ActionView::Helpers::TextHelper

    attr_accessor :comment

    def set_headers(comment_id)
      @comment = Comment.find_by_id(comment_id)

      if mail?
        @headers[:from] = "[#{@comment.author.name} (Diaspora*)] <#{AppConfig[:smtp_sender_address]}>"
        @headers[:subject] = truncate(@comment.parent.comment_email_subject, :length => TRUNCATION_LEN)
        @headers[:subject] = "Re: #{@headers[:subject]}"
      end
    end

    def mail?
      @recipient && @sender && @comment
    end
  end
end
