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
    AccountDeleter.new(bob.person.diaspora_handle).user.should == bob
    AccountDeleter.new(remote_raphael.diaspora_handle).user.should == nil
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
          @account_deletion.should_receive(method)
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
          @person_deletion.should_not_receive(method)
        end
      end

      (person_removal_methods).each do |method|

        it "calls ##{method.to_s}" do
          @person_deletion.should_receive(method)
        end
      end
    end

  end

  describe "#delete_standard_user_associations" do
    it 'removes all standard user associaltions' do
      @account_deletion.normal_ar_user_associates_to_delete.each do |asso|
        association_double = double
        association_double.should_receive(:delete)
        bob.should_receive(asso).and_return([association_double])
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
        association_double.should_receive(:delete_all)
        bob.person.should_receive(asso).and_return(association_double)
      end

      @account_deletion.delete_standard_person_associations
    end
  end

  describe "#disassociate_invitations" do
    it "sets invitations_from_me to be admin invitations" do
      invites = [double]
      bob.stub(:invitations_from_me).and_return(invites)
      invites.first.should_receive(:convert_to_admin!)
      @account_deletion.disassociate_invitations
    end
  end

  context 'person associations' do
    describe '#disconnect_contacts' do
      it "deletes all of user's contacts" do
        bob.contacts.should_receive(:destroy_all)
        @account_deletion.disconnect_contacts
      end
    end

    describe '#delete_contacts_of_me' do
      it 'deletes all the local contact objects where deleted account is the person' do
        contacts = double
        Contact.should_receive(:all_contacts_of_person).with(bob.person).and_return(contacts)
        contacts.should_receive(:destroy_all)
        @account_deletion.delete_contacts_of_me
      end
    end

    describe '#tombstone_person_and_profile' do
      it 'calls clear_profile! on person' do
        @account_deletion.person.should_receive(:clear_profile!)
        @account_deletion.tombstone_person_and_profile
      end

      it 'calls lock_access! on person' do
        @account_deletion.person.should_receive(:lock_access!)
        @account_deletion.tombstone_person_and_profile
      end
    end
     describe "#remove_conversation_visibilities" do
      it "removes the conversation visibility for the deleted user" do
        vis = double
        ConversationVisibility.should_receive(:where).with(hash_including(:person_id => bob.person.id)).and_return(vis)
        vis.should_receive(:destroy_all)
        @account_deletion.remove_conversation_visibilities
      end
    end
  end

  describe "#remove_person_share_visibilities" do
    it 'removes the share visibilities for a person ' do
      @s_vis = double
      ShareVisibility.should_receive(:for_contacts_of_a_person).with(bob.person).and_return(@s_vis)
      @s_vis.should_receive(:destroy_all)

      @account_deletion.remove_share_visibilities_on_persons_posts
    end
  end

  describe "#remove_share_visibilities_by_contacts_of_user" do
    it 'removes the share visibilities for a user' do
      @s_vis = double
      ShareVisibility.should_receive(:for_a_users_contacts).with(bob).and_return(@s_vis)
      @s_vis.should_receive(:destroy_all)

      @account_deletion.remove_share_visibilities_on_contacts_posts
    end
  end

  describe "#tombstone_user" do
    it 'calls strip_model on user' do
      bob.should_receive(:clear_account!)
      @account_deletion.tombstone_user
    end
  end

  it 'has all user association keys accounted for' do
    all_keys = (@account_deletion.normal_ar_user_associates_to_delete + @account_deletion.special_ar_user_associations + @account_deletion.ignored_ar_user_associations)
    all_keys.sort{|x, y| x.to_s <=> y.to_s}.should == User.reflections.keys.sort{|x, y| x.to_s <=> y.to_s}
  end

  it 'has all person association keys accounted for' do
    all_keys = (@account_deletion.normal_ar_person_associates_to_delete + @account_deletion.ignored_or_special_ar_person_associations)
    all_keys.sort{|x, y| x.to_s <=> y.to_s}.should == Person.reflections.keys.sort{|x, y| x.to_s <=> y.to_s}
  end
end

