# frozen_string_literal: true

describe Export::OthersDataSerializer do
  let(:user) { FactoryGirl.create(:user) }
  let(:serializer) { Export::OthersDataSerializer.new(user.id) }

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
  end
end
