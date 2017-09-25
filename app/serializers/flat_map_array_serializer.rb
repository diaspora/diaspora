# frozen_string_literal: true

class FlatMapArraySerializer < ActiveModel::ArraySerializer
  def serializable_object(options={})
    @object.flat_map do |subarray|
      subarray.map do |item|
        serializer_for(item).serializable_object_with_notification(options)
      end
    end
  end
end
