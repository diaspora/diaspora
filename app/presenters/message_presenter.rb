# frozen_string_literal: true

class MessagePresenter < BasePresenter
  def as_api_json
    {
      guid:       @presentable.guid,
      created_at: @presentable.created_at,
      body:       @presentable.text,
      author:     PersonPresenter.new(@presentable.author).as_api_json
    }
  end
end
