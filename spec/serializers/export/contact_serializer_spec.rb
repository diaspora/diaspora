# frozen_string_literal: true

describe Export::ContactSerializer do
  let(:contact) { FactoryGirl.create(:contact) }
  let(:serializer) { Export::ContactSerializer.new(contact) }
  let(:aspect) { FactoryGirl.create(:aspect) }

  it "has contact attributes" do
    expect(serializer.attributes).to eq(
      sharing:     contact.sharing,
      following:   contact.sharing,
      receiving:   contact.receiving,
      followed:    contact.receiving,
      person_guid: contact.person_guid,
      person_name: contact.person_name,
      account_id:  contact.person_diaspora_handle,
      public_key:  contact.person.serialized_public_key
    )
  end

  it "serializes aspects membership" do
    contact.aspects << aspect
    expect(Export::ContactSerializer).to serialize_association(:contact_groups_membership)
      .with_objects(contact.aspects.map(&:name))
    expect(serializer.associations[:contact_groups_membership]).to eq([aspect.name])
  end
end
