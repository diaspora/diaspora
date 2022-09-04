# frozen_string_literal: true

class LastThreeCommentsDecorator
  def initialize(presenter)
    @presenter = presenter
  end

  def as_json(_options={})
    current_user = @presenter.current_user
    @presenter.as_json.tap do |post|
      post[:interactions].merge!(comments: CommentPresenter.as_collection(
        @presenter.post.last_three_comments,
        :as_json,
        current_user
      ))
    end
  end
end
