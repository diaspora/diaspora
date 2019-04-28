# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

shared_examples_for "deletes all of the user data" do
  it "deletes all of the user data" do
    expect(user).not_to be_a_clear_account

    expect {
      account_removal_method
    }.to change(nil, "user preferences empty?") { UserPreference.where(user_id: user.id).empty? }
      .to(be_truthy)
      .and(change(nil, "notifications empty?") { Notification.where(recipient_id: user.id).empty? }.to(be_truthy))
      .and(change(nil, "blocks empty?") { Block.where(user_id: user.id).empty? }.to(be_truthy))
      .and(change(nil, "services empty?") { Service.where(user_id: user.id).empty? }.to(be_truthy))
      .and(change(nil, "share visibilities empty?") { ShareVisibility.where(user_id: user.id).empty? }.to(be_truthy))
      .and(change(nil, "aspects empty?") { user.aspects.empty? }.to(be_truthy))
      .and(change(nil, "contacts empty?") { user.contacts.empty? }.to(be_truthy))
      .and(change(nil, "tag followings empty?") { user.tag_followings.empty? }.to(be_truthy))

    expect(user.reload).to be_a_clear_account
  end
end

shared_examples_for "it removes the person associations" do
  it "removes all of the person associations" do
    expect {
      account_removal_method
    }.to change(nil, "posts empty?") { Post.where(author_id: person.id).empty? }.to(be_truthy)
      .and(change(nil, "contacts empty?") { Contact.where(person_id: person.id).empty? }.to(be_truthy))
      .and(change(nil, "mentions empty?") { person.mentions.empty? }.to(be_truthy))
      .and(change(nil, "photos empty?") { Photo.where(author_id: person.id).empty? }.to(be_truthy))
      .and(change(nil, "participations empty?") { Participation.where(author_id: person.id).empty? }.to(be_truthy))
      .and(change(nil, "roles empty?") { Role.where(person_id: person.id).empty? }.to(be_truthy))
      .and(change(person, :closed_account).to(be_truthy))
      .and(change(nil, "first name is blank?") { person.profile.first_name.blank? }.to(be_truthy))
      .and(change(nil, "last name is blank?") { person.profile.last_name.blank? }.to(be_truthy))
      .and(change(nil, "conversation visibilities empty?") {
        ConversationVisibility.where(person_id: person.id).empty?
      }.to(be_truthy))
  end
end

shared_examples_for "it keeps the person conversations" do
  it "remains the person conversations" do
    expect {
      account_removal_method
    }.to remain(nil, "conversations empty?") { Conversation.where(author: person).empty? }
      .from(be_falsey)
      .and(remain(nil, "conversation visibilities of other participants empty?") {
        ConversationVisibility.where(conversation: Conversation.where(author: person)).empty?
      }.from(be_falsey))
  end
end

# In fact this example group if for testing effect of AccountDeleter.tombstone_person_and_profile
shared_examples_for "it makes account closed and clears profile" do
  it "" do
    expect(subject).to be_a_closed_account
    expect(subject.profile).to be_a_clear_profile
  end
end
