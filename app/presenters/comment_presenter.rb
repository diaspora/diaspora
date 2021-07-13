# frozen_string_literal: true

class CommentPresenter < BasePresenter
  def as_json(opts={})
    {
      id:               id,
      guid:             guid,
      text:             message.plain_text_for_json,
      author:           author.as_api_response(:backbone),
      created_at:       created_at,
      mentioned_people: mentioned_people.as_api_response(:backbone),
      interactions:     build_interactions_json
    }
  end

  def as_api_response
    {
      guid:             guid,
      body:             message.plain_text_for_json,
      author:           PersonPresenter.new(author).as_api_json,
      created_at:       created_at,
      mentioned_people: build_mentioned_people_json,
      reported:         current_user.present? && reports.exists?(user: current_user),
      interactions:     build_interactions_json
    }
  end

  def build_interactions_json
    {
      likes:       as_api(likes),
      likes_count: likes_count
    }
  end

  def build_mentioned_people_json
    mentioned_people.map {|m| PersonPresenter.new(m).as_api_json }
  end

  def as_api(collection)
    collection.includes(author: :profile).map {|element|
      element.as_api_response(:backbone)
    }
  end
end
