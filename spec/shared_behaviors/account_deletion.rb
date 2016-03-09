#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

shared_examples_for 'it removes the person associations' do
  it "removes all of the person's posts" do
    expect(Post.where(author_id: person.id).count).to eq(0)
  end

  it 'deletes all person contacts' do
    expect(Contact.where(person_id: person.id)).to be_empty
  end

  it 'deletes all mentions' do
    expect(person.mentions).to be_empty
  end

  it "removes all of the person's photos" do
    expect(Photo.where(author_id: person.id)).to be_empty
  end

  it "deletes all person's participations" do
    expect(Participation.where(author_id: person.id)).to be_empty
  end

  it "deletes all person's roles" do
    expect(Role.where(person_id: person.id)).to be_empty
  end

  it 'sets the person object as closed and the profile is cleared' do
    expect(person.reload.closed_account).to be true

    expect(person.profile.first_name).to be_blank
    expect(person.profile.last_name).to be_blank
  end

  it "deletes all the converersation visibilities for the deleted user" do
    expect(ConversationVisibility.where(person_id: person.id)).to be_empty
  end

  it "doesn't delete the conversations of the user" do
    expect(Conversation.where(author: person)).not_to be_empty
  end

  it "doesn't delete the converersation visibilities for other participants in the user's conversations" do
    expect(ConversationVisibility.where(conversation: Conversation.where(author: person))).not_to be_empty
  end
end
