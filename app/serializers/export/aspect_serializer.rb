module Export
  class AspectSerializer < ActiveModel::Serializer
    attributes :name,
               :contacts_visible,
               :chat_enabled
  end
end
