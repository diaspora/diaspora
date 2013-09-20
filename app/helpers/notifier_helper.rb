module NotifierHelper
  
  # @param post [Post] The post object.
  # @param opts [Hash] Optional hash.  Accepts :length and :process_newlines parameters.
  # @return [String] The truncated and formatted post.
  def post_message(post, opts={})
    opts[:length] ||= 200
    if post.respond_to? :formatted_message
      message = strip_markdown(post.formatted_message(:plain_text => true))
      message = truncate(message, :length => opts[:length])
      message = process_newlines(message) if opts[:process_newlines]
      message
    else
      I18n.translate 'notifier.a_post_you_shared'
    end
  end

  # @param comment [Comment] The comment to process.
  # @param opts [Hash] Optional hash.  Accepts :length and :process_newlines parameters.
  # @return [String] The truncated and formatted comment.
  def comment_message(comment)
    I18n.t('notifier.comment_on_post.post_activity', link: post_comment_url(comment.post, comment))
  end
end
