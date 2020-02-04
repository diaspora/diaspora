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
        large:  url(:scaled_full),
        raw:    url
      }
    }
  end

  def as_api_json(full=false)
    api_json = {
      dimensions: {
        height: height,
        width:  width
      },
      sizes:      {
        small:  url(:thumb_small),
        medium: url(:thumb_medium),
        large:  url(:scaled_full),
        raw:    url
      }
    }

    api_json[:guid] = guid if full
    api_json[:created_at] = created_at if full
    api_json[:post] = status_message_guid if full && status_message_guid
    api_json
  end
end
