# frozen_string_literal: true

describe NotificationPresenter do
  it "makes json with target" do
    post = FactoryGirl.create(:status_message)
    notification = FactoryGirl.create(:notification, recipient: alice, target: post)
    json = NotificationPresenter.new(notification).as_api_json
    expect(json[:guid]).to eq(notification.guid)
    expect(json[:type]).to eq("also_commented")
    expect(json[:read]).to be_falsey
    expect(json[:created_at]).to eq(notification.created_at)
    expect(json[:target][:guid]).to eq(post.guid)
    expect(json[:event_creators].length).to eq(1)
  end

  it "returns target on mentioned" do
    mentioned_post = FactoryGirl.create(:status_message_in_aspect, author: alice.person, text: text_mentioning(bob))
    Notifications::MentionedInPost.notify(mentioned_post, [bob.id])
    notification = Notifications::MentionedInPost.last
    json = NotificationPresenter.new(notification).as_api_json
    expect(json[:target][:guid]).to eq(mentioned_post.guid)
  end

  it "returns target on mentioned in comment" do
    post = FactoryGirl.create(:status_message, public: true)
    mentioned_comment = FactoryGirl.create(:comment, post: post, author: alice.person, text: text_mentioning(bob))
    Notifications::MentionedInComment.notify(mentioned_comment, [bob.id])
    notification = Notifications::MentionedInComment.last
    json = NotificationPresenter.new(notification).as_api_json
    expect(json[:target][:guid]).to eq(mentioned_comment.post.guid)
  end

  it "returns target on also_commented" do
    post = FactoryGirl.create(:status_message)
    bob.comment!(post, "cool")
    comment2 = FactoryGirl.create(:comment, post: post)
    Notifications::AlsoCommented.notify(comment2, [])
    notification = Notifications::AlsoCommented.last
    json = NotificationPresenter.new(notification).as_api_json
    expect(json[:target][:guid]).to eq(post.guid)
  end

  it "returns no target on started_sharing" do
    contact = FactoryGirl.create(:contact)
    Notifications::StartedSharing.notify(contact, [bob.id])
    notification = Notifications::StartedSharing.last
    json = NotificationPresenter.new(notification).as_api_json
    expect(json[:target]).to be_nil
  end

  it "returns no target on contacts_birthday" do
    contact = FactoryGirl.create(:contact)
    Notifications::ContactsBirthday.notify(contact, [bob.id])
    notification = Notifications::ContactsBirthday.last
    json = NotificationPresenter.new(notification).as_api_json
    expect(json[:target]).to be_nil
  end
end
