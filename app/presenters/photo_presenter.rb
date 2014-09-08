class PhotoPresenter < BasePresenter
  def base_hash
    { id: id,
      guid: guid,
      dimensions: {
        h: height,
        w: width
      },
      sizes: {
        s: url(:thumb_small),
        m: url(:thumb_medium),
        l: url(:scaled_full)
      }
    }
  end
end
