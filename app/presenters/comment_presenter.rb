class CommentPresenter < BasePresenter
  def initialize(comment)
    @comment = comment
  end

  def as_json(_opts = {})
    {
      id: @comment.id,
      guid: @comment.guid,
      text: @comment.message.plain_text_for_json,
      author: @comment.author.as_api_response(:backbone),
      created_at: @comment.created_at
    }
  end
end
