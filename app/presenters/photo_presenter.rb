# frozen_string_literal: true

class PhotoPresenter < BasePresenter
  def base_hash
    { id: id,
      guid: guid,
      dimensions: {
        height: height,
        width: width
      },
      sizes: {
        small: url(:thumb_small),
        medium: url(:thumb_medium),
        large: url(:scaled_full)
      }
    }
  end
end
