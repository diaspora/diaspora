
class Backbone::MessagePresenter < BasePresenter
  def base_hash
    { id: id,
      guid: guid,
      text: text,
      updated_at: updated_at
    }
  end

  def full_hash
    base_hash.merge({
      author: AuthorPresenter.new(author).full_hash
    })
  end
end
