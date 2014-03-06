module NotifierHelper

  # @param post [Post] The post object.
  # @param opts [Hash] Optional hash. Accepts the :process_newlines parameter.
  # @return [String] The formatted post.
  def post_message(post, opts={})
    if post.respond_to? :formatted_message
      message = strip_markdown(post.formatted_message(:plain_text => true))
      message = process_newlines(message) if opts[:process_newlines]
      message.html_safe
    else
      I18n.translate 'notifier.a_post_you_shared'
    end
  end

  # @param comment [Comment] The comment to process.
  # @param opts [Hash] Optional hash. Accepts the :process_newlines parameter.
  # @return [String] The formatted comment.
  def comment_message(comment, opts={})
    text = strip_markdown(comment.text)
    text = process_newlines(text) if opts[:process_newlines]
    text
  end
end
