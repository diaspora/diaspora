def expect_for_sharing_notification(user1, user2)
  notifications = user1.wait_for_notification("started_sharing")

  expect(notifications.count).to be > 0
  expect(notifications.first["started_sharing"]["target_id"]).to eq(user1.remote_person(user2.diaspora_id)["id"])
end
