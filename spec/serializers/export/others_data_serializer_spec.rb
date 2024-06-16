# frozen_string_literal: true

describe Export::OthersDataSerializer do
  let(:user) { FactoryBot.create(:user) }
  let(:serializer) { Export::OthersDataSerializer.new(user.id) }

  it "uses FederationEntitySerializer for array serializing relayables" do
    sm = DataGenerator.new(user).status_message_with_activity

    expect(Export::OthersDataSerializer).to serialize_association(:relayables)
      .with_each_serializer(FederationEntitySerializer)
      .with_objects([*sm.likes, *sm.comments, *sm.poll_participations])
    serializer.associations
  end

  it "uses old local user private key if the author was migrated away from the pod" do
    post = DataGenerator.new(user).status_message_with_activity

    old_comment_author = post.comments.first.author
    AccountMigration.create!(old_person: old_comment_author, new_person: FactoryBot.create(:person)).perform!

    serializer.associations[:relayables].select {|r| r[:entity_type] == "comment" }.each do |comment|
      expect(comment[:entity_data][:author]).to eq(old_comment_author.diaspora_handle)
    end
  end
end
