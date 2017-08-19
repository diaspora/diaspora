describe Export::OthersDataSerializer do
  let(:user) { FactoryGirl.create(:user) }
  let(:serializer) { Export::OthersDataSerializer.new(user) }
  let(:others_posts) {
    [
      *user.person.likes.map(&:target),
      *user.person.comments.map(&:parent),
      *user.person.posts.reshares.map(&:root),
      *user.person.poll_participations.map(&:status_message)
    ]
  }

  it "uses FederationEntitySerializer for array serializing relayables" do
    sm = DataGenerator.new(user).status_message_with_activity

    expect(Export::OthersDataSerializer).to serialize_association(:relayables)
      .with_each_serializer(FederationEntitySerializer)
      .with_objects([*sm.likes, *sm.comments, *sm.poll_participations])
    serializer.associations
  end

  context "with user's activity" do
    before do
      DataGenerator.new(user).activity
    end

    it "uses FederationEntitySerializer for array serializing posts" do
      expect(Export::OthersDataSerializer).to serialize_association(:posts)
        .with_each_serializer(FederationEntitySerializer)
        .with_objects(others_posts)
      serializer.associations
    end

    it "uses PersonMetadataSerializer for array serializing non_contact_authors" do
      non_contact_authors = others_posts.map(&:author)

      expect(Export::OthersDataSerializer).to serialize_association(:non_contact_authors)
        .with_each_serializer(Export::PersonMetadataSerializer)
        .with_objects(non_contact_authors)
      serializer.associations
    end
  end
end
