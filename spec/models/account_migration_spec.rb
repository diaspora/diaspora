# frozen_string_literal: true

require "integration/federation/federation_helper"

describe AccountMigration, type: :model do
  describe "create!" do
    include_context "with local old user"

    it "locks old local user after creation" do
      expect {
        AccountMigration.create!(old_person: old_person, new_person: FactoryGirl.create(:person))
      }.to change { old_user.reload.access_locked? }.to be_truthy
    end
  end

  let(:old_person) { FactoryGirl.create(:person) }
  let(:new_person) { FactoryGirl.create(:person) }
  let(:account_migration) {
    AccountMigration.create!(old_person: old_person, new_person: new_person)
  }

  describe "receive" do
    it "calls perform!" do
      expect(account_migration).to receive(:perform!)
      account_migration.receive
    end
  end

  describe "sender" do
    context "with remote old user" do
      include_context "with remote old user"

      it "creates ephemeral user when private key is provided" do
        account_migration.old_private_key = old_user.serialized_private_key
        sender = account_migration.sender
        expect(sender.id).to eq(old_user.diaspora_handle)
        expect(sender.diaspora_handle).to eq(old_user.diaspora_handle)
        expect(sender.encryption_key.to_s).to eq(old_user.encryption_key.to_s)
      end

      it "raises when no private key is provided" do
        expect {
          account_migration.sender
        }.to raise_error("can't build sender without old private key defined")
      end
    end

    context "with local old user" do
      include_context "with local old user"

      it "matches the old user" do
        expect(account_migration.sender).to eq(old_user)
      end
    end
  end

  describe "performed?" do
    it "is changed after perform!" do
      expect {
        account_migration.perform!
      }.to change(account_migration, :performed?).to be_truthy
    end

    it "calls old_person.closed_account?" do
      expect(account_migration.old_person).to receive(:closed_account?)
      account_migration.performed?
    end
  end

  context "with local new user" do
    include_context "with local new user"

    describe "subscribers" do
      it "picks remote subscribers of new user profile and old person" do
        _local_friend, remote_contact = DataGenerator.create(new_user, %i[mutual_friend remote_mutual_friend])
        expect(account_migration.new_person.owner.profile).to receive(:subscribers).and_call_original
        expect(account_migration.subscribers).to match_array([remote_contact.person, old_person])
      end

      context "with local old user" do
        include_context "with local old user"

        it "doesn't include old person" do
          expect(account_migration.subscribers).to be_empty
        end
      end
    end
  end

  describe "perform!" do
    # TODO: add references update tests
    # This spec is missing references update tests. We didn't come with a good idea of how to test it
    # and it is currently covered by integration tests. But it's beter to add these tests at some point
    # in future when we have more time to think about it.

    let(:embedded_account_deleter) { account_migration.send(:account_deleter) }

    it "raises if already performed" do
      expect(account_migration).to receive(:performed?).and_return(true)
      expect {
        account_migration.perform!
      }.to raise_error("already performed")
    end

    it "calls AccountDeleter#tombstone_person_and_profile" do
      expect(embedded_account_deleter).to receive(:tombstone_person_and_profile)
      account_migration.perform!
    end

    context "with local old and remote new users" do
      include_context "with local old user"

      it "calls AccountDeleter#close_user" do
        expect(embedded_account_deleter).to receive(:close_user)
        account_migration.perform!
      end

      it "resends contacts to the remote pod" do
        contact = FactoryGirl.create(:contact, person: old_person, sharing: true)
        expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch).with(contact.user, contact)
        account_migration.perform!
      end
    end

    context "with local new and remote old users" do
      include_context "with remote old user"
      include_context "with local new user"

      it "dispatches account migration message" do
        expect(account_migration).to receive(:sender).twice.and_return(old_user)
        dispatcher = double
        expect(dispatcher).to receive(:dispatch)
        expect(Diaspora::Federation::Dispatcher).to receive(:build)
          .with(old_user, account_migration)
          .and_return(dispatcher)
        account_migration.perform!
      end

      it "doesn't run migration if old key is not provided" do
        expect(embedded_account_deleter).not_to receive(:tombstone_person_and_profile)

        expect {
          account_migration.perform!
        }.to raise_error "can't build sender without old private key defined"
      end
    end

    context "with local old and new users" do
      include_context "with local old user"
      include_context "with local new user"

      it "calls AccountDeleter#tombstone_user" do
        expect(embedded_account_deleter).to receive(:tombstone_user)
        account_migration.perform!
      end
    end
  end
end
