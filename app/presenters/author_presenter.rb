
class AuthorPresenter < BasePresenter
  def base_hash
    { id: id,
      guid: guid,
      name: name,
      diaspora_id: diaspora_handle
    }
  end

  def full_hash
    base_hash.merge({
      avatar: {
        small: profile.image_url(:thumb_small),
        medium: profile.image_url(:thumb_medium),
        large: profile.image_url(:thumb_large)
      }
    })
  end
end
