class CommentPresenter < BasePresenter
  def initialize(comment)
    @comment = comment
  end

  def as_json(opts={})
    {
      :id => @comment.id,
      :guid => @comment.guid,
      :text  => @comment.text,
      :author => @comment.author.as_api_response(:backbone),
      :created_at => @comment.created_at
    }
  end
end