# frozen_string_literal: true

class LastThreeCommentsDecorator
  def initialize(presenter)
    @presenter = presenter
  end

  def as_json(options={})
    @presenter.as_json.tap do |post|
      post[:interactions].merge!(:comments => CommentPresenter.as_collection(@presenter.post.last_three_comments))
    end
  end
end