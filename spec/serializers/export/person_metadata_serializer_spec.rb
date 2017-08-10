describe Export::PersonMetadataSerializer do
  let(:person) { FactoryGirl.create(:person) }
  let(:serializer) { Export::PersonMetadataSerializer.new(person) }

  it "has person metadata attributes" do
    expect(serializer.attributes).to eq(
      guid:       person.guid,
      account_id: person.diaspora_handle,
      public_key: person.serialized_public_key
    )
  end
end
