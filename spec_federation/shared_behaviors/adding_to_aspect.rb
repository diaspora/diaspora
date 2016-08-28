require "common_expectations"

shared_examples_for "adding to aspect" do
  before do
    expect(user0.add_to_first_aspect(user1)).to be_truthy
  end

  it "two users set up sharing correctly" do
    notifications = user1.wait_for_notification("started_sharing")

    expect(notifications.count).to be > 0
    expect(notifications.first["started_sharing"]["target_id"]).to eq(user1.remote_person(user0.diaspora_id)["id"])
  end
end
