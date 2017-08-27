
# frozen_string_literal: true

class AvatarPresenter < BasePresenter
  DEFAULT_IMAGE = ActionController::Base.helpers.image_path("user/default.png")

  def base_hash
    {
      small:  small,
      medium: medium,
      large:  large
    }
  end

  def small
    image_url(:thumb_small) || DEFAULT_IMAGE
  end

  def medium
    image_url(:thumb_medium) || DEFAULT_IMAGE
  end

  def large
    image_url || DEFAULT_IMAGE
  end
end
