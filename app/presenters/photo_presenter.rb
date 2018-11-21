# frozen_string_literal: true

class PhotoPresenter < BasePresenter
  def base_hash
    {
      id:         id,
      guid:       guid,
      dimensions: {
        height: height,
        width:  width
      },
      sizes:      {
        small:  url(:thumb_small),
        medium: url(:thumb_medium),
        large:  url(:scaled_full)
      }
    }
  end

  def as_api_json(no_guid=true)
    based_data = {
      dimensions: {
        height: height,
        width:  width
      },
      sizes:      {
        small:  url(:thumb_small),
        medium: url(:thumb_medium),
        large:  url(:scaled_full)
      }
    }
    return based_data if no_guid
    based_data.merge(guid: guid)
  end
end
