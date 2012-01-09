module NotificationMailers
  class CommentOnPost < NotificationMailers::Base
    include ActionView::Helpers::TextHelper

    attr_accessor :comment, :text_owner

    def set_headers(comment_id)
      @comment = Comment.find(comment_id)
      @text_owner = @comment.author.owner
      @post_owner = @comment.parent.author.owner
      @post_author_name = @comment.post.author.name

      @headers[:from] = "\"#{@comment.author.name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
      @headers[:subject] = @post_owner.user_preferences.exists?(:email_type => 'silent') ? "#{I18n.t('notifier.comment_on_post.silenced_subject', :name => "#{@post_author_name}")}" : truncate(@comment.parent.comment_email_subject, :length => TRUNCATION_LEN)
      @headers[:subject] = "Re: #{@headers[:subject]}"
    end
  end
end
