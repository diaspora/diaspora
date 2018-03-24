# frozen_string_literal: true

# This module encapsulates knowledge about the way AMS works with the serializable object.
# The main responsibility of this module is to allow changing resulting object just before the
# JSON serialization happens.
module SerializerPostProcessing
  # serializable_object output is used in AMS to produce a hash from input object that is passed to JSON serializer.
  # serializable_object of ActiveModel::Serializer is not documented as officialy available API
  # NOTE: if we ever move to AMS 0.10, this method was renamed there to serializable_hash
  def serializable_object(options={})
    modify_serializable_object(super)
  end

  # Users of this module may override this method in order to change serializable_object after
  # the serializable hash generation and before its serialization.
  def modify_serializable_object(hash)
    hash
  end

  # except is an array of keys that are excluded from serialized_object before JSON serialization
  attr_accessor :except
end
