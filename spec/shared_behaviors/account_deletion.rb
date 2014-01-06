#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

shared_examples_for 'it removes the person associations' do
  it "removes all of the person's posts" do
    Post.where(:author_id => @person.id).count.should == 0
  end

  it 'deletes all person contacts' do
    Contact.where(:person_id => @person.id).should be_empty
  end

  it 'deletes all mentions' do
    @person.mentions.should be_empty
  end

  it "removes all of the person's photos" do
    Photo.where(:author_id => @person.id).should be_empty
  end

  it 'sets the person object as closed and the profile is cleared' do
    @person.reload.closed_account.should  be_true

    @person.profile.reload.first_name.should  be_blank
    @person.profile.reload.last_name.should  be_blank
  end

  it 'deletes only the converersation visibility for the deleted user' do
    ConversationVisibility.where(:person_id => alice.person.id).should_not be_empty
    ConversationVisibility.where(:person_id => @person.id).should be_empty
  end

  it "deletes the share visibilities on the person's posts" do
    ShareVisibility.for_contacts_of_a_person(@person).should be_empty
  end
end
