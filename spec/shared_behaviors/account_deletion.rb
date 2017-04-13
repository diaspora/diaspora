#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

shared_examples_for "it removes the person associations" do
  RSpec::Matchers.define_negated_matcher :remain, :change

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
      .and(remain(nil, "conversations empty?") { Conversation.where(author: person).empty? }.from(be_falsey))
      .and(remain(nil, "conversation visibilities of other participants empty?") {
        ConversationVisibility.where(conversation: Conversation.where(author: person)).empty?
      }.from(be_falsey))
  end
end
