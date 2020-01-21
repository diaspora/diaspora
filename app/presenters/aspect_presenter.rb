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

  def as_api_json(full=false, with_order: true)
    values = {
      id:   @aspect.id,
      name: @aspect.name
    }
    values[:order] = @aspect.order_id if with_order
    values
  end

  def to_json(options={})
    as_json.to_json(options)
  end
end
