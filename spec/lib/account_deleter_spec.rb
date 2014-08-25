#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AccountDeleter do
  before do
    @account_deletion = AccountDeleter.new(bob.person.diaspora_handle)
    @account_deletion.user = bob
  end

  it "attaches the user" do
    expect(AccountDeleter.new(bob.person.diaspora_handle).user).to eq(bob)
    expect(AccountDeleter.new(remote_raphael.diaspora_handle).user).to eq(nil)
  end

  describe '#perform' do


    user_removal_methods = [:delete_standard_user_associations,
     :disassociate_invitations,
     :remove_share_visibilities_on_contacts_posts,
     :disconnect_contacts,
     :tombstone_user]

    person_removal_methods = [:delete_contacts_of_me,
     :delete_standard_person_associations,
     :tombstone_person_and_profile,
     :remove_share_visibilities_on_persons_posts,
     :remove_conversation_visibilities]

    context "user deletion" do
      after do
        @account_deletion.perform!
      end

      (user_removal_methods + person_removal_methods).each do |method|

        it "calls ##{method.to_s}" do
          expect(@account_deletion).to receive(method)
        end
      end
    end

    context "person deletion" do
      before do
        @person_deletion = AccountDeleter.new(remote_raphael.diaspora_handle)
      end

      after do
        @person_deletion.perform!
      end

      (user_removal_methods).each do |method|

        it "does not call ##{method.to_s}" do
          expect(@person_deletion).not_to receive(method)
        end
      end

      (person_removal_methods).each do |method|

        it "calls ##{method.to_s}" do
          expect(@person_deletion).to receive(method)
        end
      end
    end

  end

  describe "#delete_standard_user_associations" do
    it 'removes all standard user associaltions' do
      @account_deletion.normal_ar_user_associates_to_delete.each do |asso|
        association_double = double
        expect(association_double).to receive(:destroy)
        expect(bob).to receive(asso).and_return([association_double])
      end

      @account_deletion.delete_standard_user_associations
    end
  end

  describe "#delete_standard_person_associations" do
    before do
      @account_deletion.person = bob.person
    end
    it 'removes all standard person associaltions' do
      @account_deletion.normal_ar_person_associates_to_delete.each do |asso|
        association_double = double
        expect(association_double).to receive(:destroy_all)
        expect(bob.person).to receive(asso).and_return(association_double)
      end

      @account_deletion.delete_standard_person_associations
    end
  end

  describe "#disassociate_invitations" do
    it "sets invitations_from_me to be admin invitations" do
      invites = [double]
      allow(bob).to receive(:invitations_from_me).and_return(invites)
      expect(invites.first).to receive(:convert_to_admin!)
      @account_deletion.disassociate_invitations
    end
  end

  context 'person associations' do
    describe '#disconnect_contacts' do
      it "deletes all of user's contacts" do
        expect(bob.contacts).to receive(:destroy_all)
        @account_deletion.disconnect_contacts
      end
    end

    describe '#delete_contacts_of_me' do
      it 'deletes all the local contact objects where deleted account is the person' do
        contacts = double
        expect(Contact).to receive(:all_contacts_of_person).with(bob.person).and_return(contacts)
        expect(contacts).to receive(:destroy_all)
        @account_deletion.delete_contacts_of_me
      end
    end

    describe '#tombstone_person_and_profile' do
      it 'calls clear_profile! on person' do
        expect(@account_deletion.person).to receive(:clear_profile!)
        @account_deletion.tombstone_person_and_profile
      end

      it 'calls lock_access! on person' do
        expect(@account_deletion.person).to receive(:lock_access!)
        @account_deletion.tombstone_person_and_profile
      end
    end
     describe "#remove_conversation_visibilities" do
      it "removes the conversation visibility for the deleted user" do
        vis = double
        expect(ConversationVisibility).to receive(:where).with(hash_including(:person_id => bob.person.id)).and_return(vis)
        expect(vis).to receive(:destroy_all)
        @account_deletion.remove_conversation_visibilities
      end
    end
  end

  describe "#remove_person_share_visibilities" do
    it 'removes the share visibilities for a person ' do
      @s_vis = double
      expect(ShareVisibility).to receive(:for_contacts_of_a_person).with(bob.person).and_return(@s_vis)
      expect(@s_vis).to receive(:destroy_all)

      @account_deletion.remove_share_visibilities_on_persons_posts
    end
  end

  describe "#remove_share_visibilities_by_contacts_of_user" do
    it 'removes the share visibilities for a user' do
      @s_vis = double
      expect(ShareVisibility).to receive(:for_a_users_contacts).with(bob).and_return(@s_vis)
      expect(@s_vis).to receive(:destroy_all)

      @account_deletion.remove_share_visibilities_on_contacts_posts
    end
  end

  describe "#tombstone_user" do
    it 'calls strip_model on user' do
      expect(bob).to receive(:clear_account!)
      @account_deletion.tombstone_user
    end
  end

  it 'has all user association keys accounted for' do
    all_keys = (@account_deletion.normal_ar_user_associates_to_delete + @account_deletion.special_ar_user_associations + @account_deletion.ignored_ar_user_associations)
    expect(all_keys.sort{|x, y| x.to_s <=> y.to_s}).to eq(User.reflections.keys.sort{|x, y| x.to_s <=> y.to_s})
  end

  it 'has all person association keys accounted for' do
    all_keys = (@account_deletion.normal_ar_person_associates_to_delete + @account_deletion.ignored_or_special_ar_person_associations)
    expect(all_keys.sort{|x, y| x.to_s <=> y.to_s}).to eq(Person.reflections.keys.sort{|x, y| x.to_s <=> y.to_s})
  end
end

