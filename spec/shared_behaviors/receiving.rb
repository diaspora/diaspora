# frozen_string_literal: true

shared_examples_for "it ignores existing object received twice" do |klass|
  it "return nil if the #{klass} already exists" do
    expect(Diaspora::Federation::Receive.perform(entity)).not_to be_nil
    expect(Diaspora::Federation::Receive.perform(entity)).to be_nil
  end

  it "does not change anything if the #{klass} already exists" do
    Diaspora::Federation::Receive.perform(entity)

    expect_any_instance_of(klass).not_to receive(:create_or_update)

    Diaspora::Federation::Receive.perform(entity)
  end
end

shared_examples_for "it rejects if the root author ignores the author" do |klass|
  it "saves the relayable if the author is not ignored" do
    Diaspora::Federation::Receive.perform(entity)

    expect(klass.find_by!(guid: entity.guid)).to be_instance_of(klass)
  end

  context "if the author is ignored" do
    before do
      alice.blocks.create(person: sender)
    end

    it "raises an error and does not save the relayable" do
      expect {
        Diaspora::Federation::Receive.perform(entity)
      }.to raise_error Diaspora::Federation::AuthorIgnored

      expect(klass.find_by(guid: entity.guid)).to be_nil
    end

    it "it sends a retraction back to the author" do
      dispatcher = double
      expect(Diaspora::Federation::Dispatcher).to receive(:build) do |retraction_sender, retraction, opts|
        expect(retraction_sender).to eq(alice)
        expect(retraction.data[:target_guid]).to eq(entity.guid)
        expect(retraction.data[:target_type]).to eq(klass.to_s)
        expect(opts).to eq(subscribers: [sender])
        dispatcher
      end
      expect(dispatcher).to receive(:dispatch)

      expect {
        Diaspora::Federation::Receive.perform(entity)
      }.to raise_error Diaspora::Federation::AuthorIgnored
    end
  end
end

shared_examples_for "it relays relayables" do |klass|
  it "dispatches the received relayable" do
    expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch) do |parent_author, relayable|
      expect(parent_author).to eq(alice)
      expect(relayable).to be_instance_of(klass)
      expect(relayable.guid).to eq(entity.guid)
    end

    Diaspora::Federation::Receive.perform(entity)
  end

  it "does not dispatch the received relayable if there was an error saving it and it exists already" do
    allow_any_instance_of(klass).to receive(:save!).and_raise(RuntimeError, "something went wrong")
    allow(Diaspora::Federation::Receive).to receive(:load_from_database).and_return(true)

    expect(Diaspora::Federation::Dispatcher).to_not receive(:defer_dispatch)

    Diaspora::Federation::Receive.perform(entity)
  end
end

shared_examples_for "it sends a participation to the author" do
  it "sends a participation for the post to the author" do
    dispatcher = double
    expect(Diaspora::Federation::Dispatcher).to receive(:build) do |user, participation, opts|
      expect(user).to be_a(User)
      expect(participation.target.guid).to eq(entity.guid)

      subscribers = opts[:subscribers]
      expect(subscribers.size).to eq(1)
      expect(subscribers.first.diaspora_handle).to eq(entity.author)

      dispatcher
    end
    expect(dispatcher).to receive(:dispatch)

    Diaspora::Federation::Receive.perform(entity)
  end

  it "doesn't save the participation in the database" do
    participation_guid = nil
    expect(Diaspora::Federation::Dispatcher).to receive(:build) do |_user, participation, _opts|
      participation_guid = participation.guid
      instance_double(:dispatch)
    end

    Diaspora::Federation::Receive.perform(entity)

    expect(Participation.where(guid: participation_guid)).not_to exist
  end

  it "uses the configured admin as sender for the participation" do
    AppConfig.admins.account = bob.username

    expect(Diaspora::Federation::Dispatcher).to receive(:build) do |user, _participation, _opts|
      expect(user.username).to eq(bob.username)
      instance_double(:dispatch)
    end

    Diaspora::Federation::Receive.perform(entity)
  end

  it "uses the first user with an admin role if no admin is configured in the config" do
    AppConfig.admins.account = nil
    admin_role = FactoryGirl.create(:role, name: "admin")

    expect(Diaspora::Federation::Dispatcher).to receive(:build) do |user, _participation, _opts|
      expect(user.username).to eq(admin_role.person.owner.username)
      instance_double(:dispatch)
    end

    Diaspora::Federation::Receive.perform(entity)
  end

  it "uses the first open account if no admin is available" do
    AppConfig.admins.account = nil
    expect(Role.admins).to be_empty
    User.first.close_account!

    expect(Diaspora::Federation::Dispatcher).to receive(:build) do |user, _participation, _opts|
      expect(user.username).to eq(User.second.username)
      instance_double(:dispatch)
    end

    Diaspora::Federation::Receive.perform(entity)
  end

  it "still receives the entity successfully if there is an error while sending the participation" do
    expect(Diaspora::Federation::Dispatcher).to receive(:build).and_raise "FooBar"

    Diaspora::Federation::Receive.perform(entity)
  end
end
