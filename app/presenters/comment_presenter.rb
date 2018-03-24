# frozen_string_literal: true

class CommentPresenter < BasePresenter
  def initialize(comment)
    @comment = comment
  end

  def as_json(opts={})
    {
      id:               @comment.id,
      guid:             @comment.guid,
      text:             @comment.message.plain_text_for_json,
      author:           @comment.author.as_api_response(:backbone),
      created_at:       @comment.created_at,
      mentioned_people: @comment.mentioned_people.as_api_response(:backbone)
    }
  end
end
