# frozen_string_literal: true

shared_context "with local old user" do
  let(:old_user) { FactoryGirl.create(:user) }
  let(:old_person) { old_user.person }
end

shared_context "with local new user" do
  let(:new_user) { FactoryGirl.create(:user) }
  let(:new_person) { new_user.person }
end

shared_context "with remote old user" do
  let(:old_user) { remote_user_on_pod_c }
  let(:old_person) { old_user.person }
end

shared_context "with remote new user" do
  let(:new_user) { remote_user_on_pod_b }
  let(:new_person) { new_user.person }
end

shared_examples_for "it updates person references" do
  it "updates contact reference" do
    contact = FactoryGirl.create(:contact, person: old_person)
    run_migration
    expect(contact.reload.person).to eq(new_person)
  end

  it "updates status message reference" do
    post = FactoryGirl.create(:status_message, author: old_person)
    run_migration
    expect(post.reload.author).to eq(new_person)
  end

  it "updates reshare reference" do
    reshare = FactoryGirl.create(:reshare, author: old_person)
    run_migration
    expect(reshare.reload.author).to eq(new_person)
  end

  it "updates photo reference" do
    photo = FactoryGirl.create(:photo, author: old_person)
    run_migration
    expect(photo.reload.author).to eq(new_person)
  end

  it "updates comment reference" do
    comment = FactoryGirl.create(:comment, author: old_person)
    run_migration
    expect(comment.reload.author).to eq(new_person)
  end

  it "updates like reference" do
    like = FactoryGirl.create(:like, author: old_person)
    run_migration
    expect(like.reload.author).to eq(new_person)
  end

  it "updates participations reference" do
    participation = FactoryGirl.create(:participation, author: old_person)
    run_migration
    expect(participation.reload.author).to eq(new_person)
  end

  it "updates poll participations reference" do
    poll_participation = FactoryGirl.create(:poll_participation, author: old_person)
    run_migration
    expect(poll_participation.reload.author).to eq(new_person)
  end

  it "updates conversation visibilities reference" do
    conversation = FactoryGirl.build(:conversation)
    FactoryGirl.create(:contact, user: old_user, person: conversation.author) if old_person.local?
    conversation.participants << old_person
    conversation.save!
    visibility = ConversationVisibility.find_by(person_id: old_person.id)
    run_migration
    expect(visibility.reload.person).to eq(new_person)
  end

  it "updates message reference" do
    message = FactoryGirl.create(:message, author: old_person)
    run_migration
    expect(message.reload.author).to eq(new_person)
  end

  it "updates conversation reference" do
    conversation = FactoryGirl.create(:conversation, author: old_person)
    run_migration
    expect(conversation.reload.author).to eq(new_person)
  end

  it "updates block references" do
    user = FactoryGirl.create(:user)
    block = user.blocks.create(person: old_person)
    run_migration
    expect(block.reload.person).to eq(new_person)
  end

  it "updates role reference" do
    role = FactoryGirl.create(:role, person: old_person)
    run_migration
    expect(role.reload.person).to eq(new_person)
  end

  it "updates notification actors" do
    notification = FactoryGirl.build(:notification)
    notification.actors << old_person
    notification.save!
    actor = notification.notification_actors.find_by(person_id: old_person.id)
    run_migration
    expect(actor.reload.person).to eq(new_person)
  end

  it "updates mention reference" do
    mention = FactoryGirl.create(:mention, person: old_person)
    run_migration
    expect(mention.reload.person).to eq(new_person)
  end
end

shared_examples_for "it updates user references" do
  it "updates invited users reference" do
    invited_user = FactoryGirl.create(:user, invited_by: old_user)
    run_migration
    expect(invited_user.reload.invited_by).to eq(new_user)
  end

  it "updates aspect reference" do
    aspect = FactoryGirl.create(:aspect, user: old_user, name: r_str)
    run_migration
    expect(aspect.reload.user).to eq(new_user)
  end

  it "updates contact reference" do
    contact = FactoryGirl.create(:contact, user: old_user)
    run_migration
    expect(contact.reload.user).to eq(new_user)
  end

  it "updates services reference" do
    service = FactoryGirl.create(:service, user: old_user)
    run_migration
    expect(service.reload.user).to eq(new_user)
  end

  it "updates user preference references" do
    pref = UserPreference.create!(user: old_user, email_type: "also_commented")
    run_migration
    expect(pref.reload.user).to eq(new_user)
  end

  it "updates tag following references" do
    tag_following = FactoryGirl.create(:tag_following, user: old_user)
    run_migration
    expect(tag_following.reload.user).to eq(new_user)
  end

  it "updates blocks refrences" do
    block = FactoryGirl.create(:block, user: old_user)
    run_migration
    expect(block.reload.user).to eq(new_user)
  end

  it "updates notification refrences" do
    notification = FactoryGirl.create(:notification, recipient: old_user)
    run_migration
    expect(notification.reload.recipient).to eq(new_user)
  end

  it "updates report refrences" do
    report = FactoryGirl.create(:report, user: old_user)
    run_migration
    expect(report.reload.user).to eq(new_user)
  end

  it "updates authorization refrences" do
    authorization = FactoryGirl.create(:auth_with_read, user: old_user)
    run_migration
    expect(authorization.reload.user).to eq(new_user)
  end

  it "updates share visibility refrences" do
    share_visibility = FactoryGirl.create(:share_visibility, user: old_user)
    run_migration
    expect(share_visibility.reload.user).to eq(new_user)
  end
end
