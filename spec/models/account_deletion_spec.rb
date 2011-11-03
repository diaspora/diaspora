#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AccountDeletion do
  before do
    @account_deletion = AccountDeletion.new(bob.person.diaspora_handle)
    @account_deletion.user = bob
  end

  it 'works' do
    pending
  end

  it "attaches the user" do
    AccountDeletion.new(bob.person.diaspora_handle).user.should == bob
    AccountDeletion.new(remote_raphael.diaspora_handle).user.should == nil
  end

  describe '#perform' do
    it 'calls delete_standard_associations' do
      @account_deletion.should_receive(:delete_standard_associations)
      @account_deletion.perform!
    end

    it 'calls disassociate_invitations' do
      @account_deletion.should_receive(:disassociate_invitations)
      @account_deletion.perform!
    end

    it 'calls delete_contacts_of_me' do
      @account_deletion.should_receive(:delete_contacts_of_me)
      @account_deletion.perform!
    end

    it 'calls delete_contacts_of_me' do
      @account_deletion.should_receive(:delete_mentions)
      @account_deletion.perform!
    end

    it 'calls disconnect_contacts' do
      @account_deletion.should_receive(:disconnect_contacts)
      @account_deletion.perform!
    end

    it 'calls delete_posts' do
      @account_deletion.should_receive(:delete_posts)
      @account_deletion.perform!
    end
  end
  
  describe "#delete_standard_associations" do
    it 'removes all standard user associaltions' do

      @account_deletion.normal_ar_user_associates_to_delete.each do |asso|
        association_mock = mock
        association_mock.should_receive(:delete_all)
        bob.should_receive(asso).and_return(association_mock)
      end

      @account_deletion.delete_standard_associations
    end
  end


  describe '#delete_posts' do
    it 'deletes all posts' do
      @account_deletion.person.posts.should_receive(:delete_all)
      @account_deletion.delete_posts
    end
  end

  describe '#delete_photos' do
    it 'deletes all photos' do
      @account_deletion.person.photos.should_receive(:delete_all)
      @account_deletion.delete_posts
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

  describe "#normal_ar_user_associates_to_delete" do
    it "has the regular associations" do
      @account_deletion.normal_ar_user_associates_to_delete.should ==
      [:tag_followings, :authorizations, :invitations_to_me, :services, :aspects, :user_preferences, :notifications] 
    end
  end

  context 'person associations' do
    describe '#delete mentions' do
      it 'deletes the mentions for people' do
        mentions = mock
        @account_deletion.person.should_receive(:mentions).and_return(mentions)
        mentions.should_receive(:delete_all)
        @account_deletion.delete_mentions
      end
    end

    describe '#disconnect_contacts' do
      it "deletes all of user's contacts" do
        bob.contacts.should_receive(:delete_all)
        @account_deletion.disconnect_contacts
      end
    end

    describe '#delete_contacts_of_me' do
      it 'deletes all the local contact objects where deleted account is the person' do
        contacts = mock
        Contact.should_receive(:all_contacts_of_person).with(bob.person).and_return(contacts)
        contacts.should_receive(:delete_all)
        @account_deletion.delete_contacts_of_me
      end
    end
  end

  it 'has all user association keys accounted for' do
    all_keys = (@account_deletion.normal_ar_user_associates_to_delete + @account_deletion.special_ar_user_associations + @account_deletion.ignored_ar_user_associations)
    all_keys.sort{|x, y| x.to_s <=> y.to_s}.should == User.reflections.keys.sort{|x, y| x.to_s <=> y.to_s}
  end
end

