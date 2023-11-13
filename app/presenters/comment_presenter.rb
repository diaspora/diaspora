# frozen_string_literal: true

class CommentPresenter < BasePresenter
  def as_json(_opts={})
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
      interactions:     build_interaction_state
    }
  end

  def build_interaction_state
    {
      liked:       current_user.present? && likes.exists?(author: current_user.person),
      likes_count: likes_count
    }
  end

  def build_interactions_json
    {
      likes:       as_api(own_likes(likes)),
      likes_count: likes_count
    }
  end

  def build_mentioned_people_json
    mentioned_people.map {|m| PersonPresenter.new(m).as_api_json }
  end

  # TODO: Only send the own_like boolean.
  # Frontend uses the same methods for post-likes as for comment-likes
  # Whenever the frontend will be refactored, just send the own_like boolean, instead of a full list of likes
  # The list of likes is already send when API requests the full list.
  def own_likes(likes)
    if current_user
      likes.where(author: current_user.person)
    else
      likes.none
    end
  end

  def as_api(collection)
    collection.includes(author: :profile).map {|element|
      element.as_api_response(:backbone)
    }
  end
end
