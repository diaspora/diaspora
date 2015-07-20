
class AvatarPresenter < BasePresenter
  DEFAULT_IMAGE = ActionController::Base.helpers.image_path("user/default.png")

  def base_hash
    {
      small:  image_url(:thumb_small) || DEFAULT_IMAGE,
      medium: image_url(:thumb_medium) || DEFAULT_IMAGE,
      large:  image_url || DEFAULT_IMAGE
    }
  end
end
