# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe AccountDeleter do
  before do
    @account_deletion = AccountDeleter.new(bob.person)
    @account_deletion.user = bob
  end

  it "attaches the user" do
    expect(AccountDeleter.new(bob.person).user).to eq(bob)
    expect(AccountDeleter.new(remote_raphael).user).to eq(nil)
  end

  describe '#perform' do
    person_removal_methods = %i[
      delete_contacts_of_me
      delete_standard_person_associations
      tombstone_person_and_profile
      remove_conversation_visibilities
    ]

    context "user deletion" do
      after do
        @account_deletion.perform!
      end

      [*person_removal_methods, :close_user].each do |method|

        it "calls ##{method.to_s}" do
          expect(@account_deletion).to receive(method)
        end
      end
    end

    context "profile deletion" do
      before do
        @profile_deletion = AccountDeleter.new(remote_raphael)
        @profile = remote_raphael.profile
      end

      it "nulls out fields in the profile" do
        @profile_deletion.perform!
        expect(@profile.reload.first_name).to be_blank
        expect(@profile.last_name).to be_blank
        expect(@profile.searchable).to be_falsey
      end

    end

    context "person deletion" do
      before do
        @person_deletion = AccountDeleter.new(remote_raphael)
      end

      after do
        @person_deletion.perform!
      end

      it "does not call #close_user" do
        expect(@person_deletion).not_to receive(:close_user)
      end

      (person_removal_methods).each do |method|

        it "calls ##{method.to_s}" do
          expect(@person_deletion).to receive(method)
        end
      end
    end

  end

  describe "#close_user" do
    user_removal_methods = %i[
      delete_standard_user_associations
      remove_share_visibilities_on_contacts_posts
      disconnect_contacts tombstone_user
    ]

    after do
      @account_deletion.perform!
    end

    user_removal_methods.each do |method|
      it "calls ##{method}" do
        expect(@account_deletion).to receive(method)
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

  context "user associations" do
    describe "#disconnect_contacts" do
      it "deletes all of user's contacts" do
        expect(bob.contacts).to receive(:destroy_all)
        @account_deletion.disconnect_contacts
      end
    end
  end

  context 'person associations' do
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

  describe "#remove_share_visibilities_by_contacts_of_user" do
    it "removes the share visibilities for a user" do
      s_vis = double
      expect(ShareVisibility).to receive(:for_a_user).with(bob).and_return(s_vis)
      expect(s_vis).to receive(:destroy_all)

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
    expect(all_keys.sort{|x, y| x.to_s <=> y.to_s}).to eq(User.reflections.keys.sort{|x, y| x.to_s <=> y.to_s}.map(&:to_sym))
  end

  it 'has all person association keys accounted for' do
    all_keys = (@account_deletion.normal_ar_person_associates_to_delete + @account_deletion.ignored_or_special_ar_person_associations)
    expect(all_keys.sort{|x, y| x.to_s <=> y.to_s}).to eq(Person.reflections.keys.sort{|x, y| x.to_s <=> y.to_s}.map(&:to_sym))
  end
end

