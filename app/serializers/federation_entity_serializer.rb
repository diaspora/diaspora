# frozen_string_literal: true

# This is an ActiveModel::Serializer based class which uses DiasporaFederation::Entity JSON serialization
# features in order to serialize local DB objects. To determine a type of entity class to use the same routines
# are used as for federation messages generation.
class FederationEntitySerializer < ActiveModel::Serializer
  include SerializerPostProcessing
  include Diaspora::Logging

  private

  def modify_serializable_object(hash)
    hash.merge(entity.to_json)
  rescue DiasporaFederation::Entities::Relayable::AuthorPrivateKeyNotFound => e
    # The author of this relayable probably migrated from this pod to a different pod,
    # and we neither have the signature nor the new private key to generate a valid signature.
    # But we can use the private key of the old user to generate the signature it had when this entity was created
    old_person = AccountMigration.joins(:old_person)
                                 .where("new_person_id = ? AND people.owner_id IS NOT NULL", object.author_id)
                                 .first.old_person
    if old_person
      logger.info "Using private key of #{old_person.diaspora_handle} to export: #{e.message}"
      object.author = old_person
      hash.merge(entity.to_json)
    else
      logger.warn "Skip entity for export because #{e.class}: #{e.message}"
    end
  end

  def entity
    Diaspora::Federation::Entities.build(object)
  end
end
