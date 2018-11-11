# frozen_string_literal: true

class AspectPresenter < BasePresenter
  def initialize(aspect)
    @aspect = aspect
  end

  def as_json
    { :id => @aspect.id,
      :name => @aspect.name,
    }
  end

  def as_api_json(full=false)
    values = {
      id:    @aspect.id,
      name:  @aspect.name,
      order: @aspect.order_id
    }

    values[:chat_enabled] = @aspect.chat_enabled if full
    values
  end

  def to_json(options={})
    as_json.to_json(options)
  end
end
