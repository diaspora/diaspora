# frozen_string_literal: true

class LikesPresenter < BasePresenter
  def as_api_json
    {
      guid:   @presentable.guid,
      author: PersonPresenter.new(@presentable.author).as_api_json
    }
  end
end
