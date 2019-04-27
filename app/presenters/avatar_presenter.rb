
# frozen_string_literal: true

class AvatarPresenter < BasePresenter
  def base_hash(with_default = false)
    avatar = {
      small:  small(with_default),
      medium: medium(with_default),
      large:  large(with_default)
    }.compact

    avatar unless avatar.empty?
  end

  def small(with_default = false)
    image_url(size: :thumb_small, fallback_to_default: with_default)
  end

  def medium(with_default = false)
    image_url(size: :thumb_medium, fallback_to_default: with_default)
  end

  def large(with_default = false)
    image_url(fallback_to_default: with_default)
  end
end
