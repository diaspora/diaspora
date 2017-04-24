module Export
  class PersonMetadataSerializer < ActiveModel::Serializer
    attributes :guid,
               :account_id,
               :public_key

    private

    def account_id
      object.diaspora_handle
    end

    def public_key
      object.serialized_public_key
    end
  end
end
