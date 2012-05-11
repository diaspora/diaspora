class LastThreeCommentsDecorator
  def initialize(presenter)
    @presenter = presenter
  end

  def as_json(options={})
    @presenter.as_json.merge({:last_three_comments => CommentPresenter.as_collection(@presenter.post.last_three_comments)})
  end
end