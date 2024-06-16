# frozen_string_literal: true

class PostInteractionPresenter
  def initialize(post, current_user)
    @post = post
    @current_user = current_user
  end

  def as_json(_options={})
    {
      likes:          as_api(@post.likes),
      reshares:       PostPresenter.as_collection(@post.reshares, :as_json, @current_user),
      comments:       CommentPresenter.as_collection(@post.comments.order("created_at ASC")),
      participations: as_api(participations),
      comments_count: @post.comments_count,
      likes_count:    @post.likes_count,
      reshares_count: @post.reshares_count
    }
  end

  def as_counters
    {
      comments: @post.comments_count,
      likes:    @post.likes_count,
      reshares: @post.reshares_count
    }
  end

  private

  def participations
    return @post.participations.none unless @current_user

    @post.participations.where(author: @current_user.person)
  end

  def as_api(collection)
    collection.includes(author: :profile).map {|element|
      element.as_api_response(:backbone)
    }
  end
end

