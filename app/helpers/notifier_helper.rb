module NotifierHelper

  # @param post [Post] The post object.
  # @param opts [Hash] Optional hash.  Accepts :length parameters.
  # @return [String] The truncated and formatted post.
  def post_message(post, opts={})
    if post.respond_to? :message
      post.message.plain_text_without_markdown truncate: opts.fetch(:length, 200)
    else
      I18n.translate 'notifier.a_post_you_shared'
    end
  end

  # @param comment [Comment] The comment to process.
  # @param opts [Hash] Optional hash.  Accepts :length parameters.
  # @return [String] The truncated and formatted comment.
  def comment_message(comment, opts={})
    comment.message.plain_text_without_markdown truncate: opts.fetch(:length, 600)
  end
end
