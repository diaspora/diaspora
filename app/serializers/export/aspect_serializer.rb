# frozen_string_literal: true

module Export
  class AspectSerializer < ActiveModel::Serializer
    attributes :name, :chat_enabled
  end
end
