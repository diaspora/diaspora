require "spec_helper"

describe "notifying" do
  let(:status_message) { FactoryGirl.create(:status_message, author: alice.person, public: true) }

  it "sends a notification when someone likes your post" do
    inlined_jobs do |queue|
      expect {
        bob.like!(status_message)
        queue.drain_all
      }.to change { alice.unread_notifications.count }.by(1).and change { ActionMailer::Base.deliveries.count }.by(1)
        .and change { bob.unread_notifications.count }.by(0)
    end
  end
end
