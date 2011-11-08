#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AccountDeletion do
  before do
    @account_deletion = AccountDeletion.new(bob.person.diaspora_handle)
    @account_deletion.user = bob
  end

  it "attaches the user" do
    AccountDeletion.new(bob.person.diaspora_handle).user.should == bob
    AccountDeletion.new(remote_raphael.diaspora_handle).user.should == nil
  end

  describe '#perform' do
    after do
      @account_deletion.perform!
    end

    [:delete_standard_associations,
     :disassociate_invitations,
     :delete_standard_associations,
     :delete_contacts_of_me,
     :delete_mentions,
     :disconnect_contacts,
     :delete_photos,
     :delete_posts,
     :tombstone_person_and_profile,
     :remove_share_visibilities,
     :remove_conversation_visibilities].each do |method|

      it "calls ##{method.to_s}" do
        @account_deletion.should_receive(method)
      end
    end
  end

  describe "#delete_standard_associations" do
    it 'removes all standard user associaltions' do
      @account_deletion.normal_ar_user_associates_to_delete.each do |asso|
        association_mock = mock
        association_mock.should_receive(:destroy_all)
        bob.should_receive(asso).and_return(association_mock)
      end

      @account_deletion.delete_standard_associations
    end
  end

  describe '#delete_posts' do
    it 'deletes all posts' do
      @account_deletion.person.posts.should_receive(:destroy_all)
      @account_deletion.delete_posts
    end
  end

  describe '#delete_photos' do
    it 'deletes all photos' do
      @account_deletion.person.photos.should_receive(:destroy_all)
      @account_deletion.delete_photos
    end
  end

  describe "#disassociate_invitations" do
    it "sets invitations_from_me to be admin invitations" do
      invites = [mock]
      bob.stub(:invitations_from_me).and_return(invites)
      invites.first.should_receive(:convert_to_admin!)
      @account_deletion.disassociate_invitations
    end
  end

  context 'person associations' do
    describe '#delete mentions' do
      it 'deletes the mentions for people' do
        mentions = mock
        @account_deletion.person.should_receive(:mentions).and_return(mentions)
        mentions.should_receive(:destroy_all)
        @account_deletion.delete_mentions
      end
    end

    describe '#disconnect_contacts' do
      it "deletes all of user's contacts" do
        bob.contacts.should_receive(:destroy_all)
        @account_deletion.disconnect_contacts
      end
    end

    describe '#delete_contacts_of_me' do
      it 'deletes all the local contact objects where deleted account is the person' do
        contacts = mock
        Contact.should_receive(:all_contacts_of_person).with(bob.person).and_return(contacts)
        contacts.should_receive(:destroy_all)
        @account_deletion.delete_contacts_of_me
      end
    end

    describe '#tombstone_person_and_profile' do
      it 'calls close_account! on person' do
        @account_deletion.person.should_receive(:close_account!)
        @account_deletion.tombstone_person_and_profile
      end
    end
     describe "#remove_conversation_visibilities" do
      it "removes the conversation visibility for the deleted user" do
        vis = stub
        ConversationVisibility.should_receive(:where).with(hash_including(:person_id => bob.person.id)).and_return(vis)
        vis.should_receive(:destroy_all)
        @account_deletion.remove_conversation_visibilities
      end
    end
  end

  describe "#remove_share_visibilities" do
    before do
      @s_vis = stub
    end

    after do
      @account_deletion.remove_share_visibilities
    end

    it 'removes the share visibilities for a person ' do
      ShareVisibility.should_receive(:for_contacts_of_a_person).with(bob.person).and_return(@s_vis)
      @s_vis.should_receive(:destroy_all)
    end

    it 'removes the share visibilities for a user' do
      ShareVisibility.should_receive(:for_a_users_contacts).with(bob).and_return(@s_vis)
      @s_vis.should_receive(:destroy_all)
    end

    it 'does not remove share visibilities for a user if the user is not present' do
      pending
      ShareVisibility.should_receive(:for_a_users_contacts).with(bob).and_return(@s_vis)
      @s_vis.should_receive(:destroy_all)
    end
  end

  it 'has all user association keys accounted for' do
    all_keys = (@account_deletion.normal_ar_user_associates_to_delete + @account_deletion.special_ar_user_associations + @account_deletion.ignored_ar_user_associations)
    all_keys.sort{|x, y| x.to_s <=> y.to_s}.should == User.reflections.keys.sort{|x, y| x.to_s <=> y.to_s}
  end
end

