#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

shared_examples_for 'it removes the person associations' do
  it "removes all of the person's posts" do
    expect(Post.where(:author_id => @person.id).count).to eq(0)
  end

  it 'deletes all person contacts' do
    expect(Contact.where(:person_id => @person.id)).to be_empty
  end

  it 'deletes all mentions' do
    expect(@person.mentions).to be_empty
  end

  it "removes all of the person's photos" do
    expect(Photo.where(:author_id => @person.id)).to be_empty
  end

  it 'sets the person object as closed and the profile is cleared' do
    expect(@person.reload.closed_account).to  be true

    expect(@person.profile.reload.first_name).to  be_blank
    expect(@person.profile.reload.last_name).to  be_blank
  end

  it 'deletes only the converersation visibility for the deleted user' do
    expect(ConversationVisibility.where(:person_id => alice.person.id)).not_to be_empty
    expect(ConversationVisibility.where(:person_id => @person.id)).to be_empty
  end
end
