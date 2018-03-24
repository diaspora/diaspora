# frozen_string_literal: true

class PodPresenter < BasePresenter
  def base_hash(*_arg)
    {
      id:            id,
      host:          host,
      port:          port,
      ssl:           ssl,
      status:        status,
      checked_at:    checked_at,
      response_time: response_time,
      offline:       offline?,
      offline_since: offline_since,
      created_at:    created_at,
      software:      software,
      error:         error
    }
  end

  alias_method :as_json, :base_hash
end
