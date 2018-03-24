# frozen_string_literal: true

describe Export::UserSerializer do
  let(:user) { FactoryGirl.create(:user) }
  let(:serializer) { Export::UserSerializer.new(user.id, root: false) }

  it "has basic user's attributes" do
    expect(serializer.attributes).to eq(
      username:                           user.username,
      email:                              user.email,
      language:                           user.language,
      private_key:                        user.serialized_private_key,
      disable_mail:                       user.disable_mail,
      show_community_spotlight_in_stream: user.show_community_spotlight_in_stream,
      auto_follow_back:                   user.auto_follow_back,
      auto_follow_back_aspect:            user.auto_follow_back_aspect,
      strip_exif:                         user.strip_exif
    )
  end

  it "uses FederationEntitySerializer to serialize user profile" do
    expect(Export::UserSerializer).to serialize_association(:profile)
      .with_serializer(FederationEntitySerializer)
      .with_object(user.profile)
    serializer.associations
  end

  it "uses AspectSerializer for array serializing contact_groups" do
    DataGenerator.create(user, %i[first_aspect work_aspect])
    expect(Export::UserSerializer).to serialize_association(:contact_groups)
      .with_each_serializer(Export::AspectSerializer)
      .with_objects([user.aspects.first, user.aspects.second])
    serializer.associations
  end

  it "uses ContactSerializer for array serializing contacts" do
    DataGenerator.create(user, %i[mutual_friend mutual_friend])
    expect(Export::UserSerializer).to serialize_association(:contacts)
      .with_each_serializer(Export::ContactSerializer)
      .with_objects([user.contacts.first, user.contacts.second])
    serializer.associations
  end

  it "uses OwnPostSerializer for array serializing posts" do
    DataGenerator.create(user, %i[public_status_message private_status_message])
    expect(Export::UserSerializer).to serialize_association(:posts)
      .with_each_serializer(Export::OwnPostSerializer)
      .with_objects([user.posts.first, user.posts.second])
    serializer.associations
  end

  it "serializes followed tags" do
    DataGenerator.create(user, %i[tag_following tag_following])
    expect(Export::UserSerializer).to serialize_association(:followed_tags)
      .with_objects([user.followed_tags.first.name, user.followed_tags.second.name])
    serializer.associations
  end

  it "uses OwnRelayablesSerializer for array serializing relayables" do
    DataGenerator.create(user, :activity)

    objects = %i[comments likes poll_participations].map do |association|
      user.person.send(association).first
    end

    expect(Export::UserSerializer).to serialize_association(:relayables)
      .with_each_serializer(Export::OwnRelayablesSerializer)
      .with_objects(objects)
    serializer.associations
  end

  it "serializes post subscriptions" do
    DataGenerator.create(user, %i[participation participation])
    subscriptions = user.person.participations.map do |participation|
      participation.target.guid
    end
    expect(Export::UserSerializer).to serialize_association(:post_subscriptions)
      .with_objects(subscriptions)
    serializer.associations
  end
end
