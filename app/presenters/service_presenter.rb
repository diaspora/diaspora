# frozen_string_literal: true

class ServicePresenter < BasePresenter
  def initialize(service)
    @service = service
  end

  def as_json
    {
      :provider => @service.provider
    }
  end

  def to_json(options = {})
    as_json.to_json(options)
  end
end