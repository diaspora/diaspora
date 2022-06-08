# frozen_string_literal: true

require "integration/federation/federation_helper"

describe AccountMigration, type: :model do
  describe "create!" do
    let(:old_user) { FactoryBot.create(:user) }
    let(:old_person) { old_user.person }

    it "locks old local user after creation" do
      expect {
        AccountMigration.create!(old_person: old_person, new_person: FactoryBot.create(:person))
      }.to change { old_user.reload.access_locked? }.to be_truthy
    end
  end

  let(:old_person) { FactoryBot.create(:person) }
  let(:new_person) { FactoryBot.create(:person) }
  let(:account_migration) {
    AccountMigration.create!(old_person:        old_person,
                             new_person:        new_person,
                             remote_photo_path: "https://diaspora.example.tld/uploads/images/")
  }

  describe "receive" do
    it "calls perform!" do
      expect(account_migration).to receive(:perform!)
      account_migration.receive
    end
  end

  describe "sender" do
    context "with remote old user" do
      let(:old_user) { remote_user_on_pod_c }
      let(:old_person) { old_user.person }

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
        }.to raise_error("can't build sender without old private key and diaspora ID defined")
      end
    end

    context "with local old user" do
      let(:old_user) { FactoryBot.create(:user) }
      let(:old_person) { old_user.person }

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

    it "is truthy when completed_at is set" do
      expect(FactoryBot.create(:account_migration, completed_at: Time.zone.now).performed?).to be_truthy
    end

    it "is falsey when completed_at is null" do
      account_migration = FactoryBot.create(:account_migration, completed_at: nil)
      account_migration.old_person.lock_access!
      expect(account_migration.performed?).to be_falsey
    end
  end

  context "with local new user" do
    let(:new_user) { FactoryBot.create(:user) }
    let(:new_person) { new_user.person }

    describe "subscribers" do
      it "picks remote subscribers of new user profile and old person" do
        _local_friend, remote_contact = DataGenerator.create(new_user, %i[mutual_friend remote_mutual_friend])
        expect(account_migration.new_person.owner.profile).to receive(:subscribers).and_call_original
        expect(account_migration.subscribers).to match_array([remote_contact.person, old_person])
      end

      context "with local old user" do
        let(:old_person) { FactoryBot.create(:user).person }

        it "doesn't include old person" do
          expect(account_migration.subscribers).to be_empty
        end
      end

      context "with contacts from the archive" do
        it "includes contacts from the archive" do
          archive_person = FactoryBot.create(:person)
          remote_contact = DataGenerator.create(new_user, :remote_mutual_friend)
          contacts = [
            {
              "sharing"                   => true,
              "receiving"                 => false,
              "following"                 => true,
              "followed"                  => false,
              "account_id"                => archive_person.diaspora_handle,
              "contact_groups_membership" => []
            },
            {
              "sharing"                   => true,
              "receiving"                 => true,
              "following"                 => true,
              "followed"                  => true,
              "account_id"                => remote_contact.person.diaspora_handle,
              "contact_groups_membership" => []
            }
          ]
          account_migration =
            AccountMigration.create!(old_person: old_person, new_person: new_person, archive_contacts: contacts)
          expect(account_migration.subscribers).to match_array([remote_contact.person, archive_person, old_person])
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
      let(:old_person) { FactoryBot.create(:user).person }

      it "calls AccountDeleter#close_user" do
        expect(embedded_account_deleter).to receive(:close_user)
        account_migration.perform!
      end

      it "resends contacts to the remote pod" do
        contact = FactoryBot.create(:contact, person: old_person, sharing: true)
        expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch).with(contact.user, contact)
        account_migration.perform!
      end

      it "cleans up old local photos" do
        photo = FactoryBot.create(:photo, author: old_person)
        photo.processed_image.store!(photo.unprocessed_image)
        photo.save!

        account_migration.perform!

        updated_photo = photo.reload
        expect(updated_photo.remote_photo_path).to eq("https://diaspora.example.tld/uploads/images/")
        expect(updated_photo.processed_image.path).to be_nil
        expect(updated_photo.unprocessed_image.path).to be_nil
      end

      it "does nothing if migration doesn't contain a new remote_photo_path" do
        photo = FactoryBot.create(:photo, author: old_person)
        photo.processed_image.store!(photo.unprocessed_image)
        photo.save!

        remote_photo_path = photo.remote_photo_path

        AccountMigration.create!(old_person: old_person, new_person: new_person).perform!

        updated_photo = photo.reload
        expect(updated_photo.remote_photo_path).to eq(remote_photo_path)
        expect(updated_photo.processed_image.path).not_to be_nil
        expect(updated_photo.unprocessed_image.path).not_to be_nil
      end
    end

    context "with local new and remote old users" do
      let(:old_user) { remote_user_on_pod_c }
      let(:old_person) { old_user.person }
      let(:new_person) { FactoryBot.create(:user).person }

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
        }.to raise_error "can't build sender without old private key and diaspora ID defined"
      end
    end

    context "with local old and new users" do
      let(:old_person) { FactoryBot.create(:user).person }
      let(:new_person) { FactoryBot.create(:user).person }

      it "calls AccountDeleter#tombstone_user" do
        expect(embedded_account_deleter).to receive(:tombstone_user)
        account_migration.perform!
      end
    end

    context "with remote account merging (non-empty new person)" do
      before do
        FactoryBot.create(
          :contact,
          person: new_person,
          user:   FactoryBot.create(:contact, person: old_person).user
        )
        FactoryBot.create(
          :like,
          author: new_person,
          target: FactoryBot.create(:like, author: old_person).target
        )
        FactoryBot.create(
          :participation,
          author: new_person,
          target: FactoryBot.create(:participation, author: old_person).target
        )
        FactoryBot.create(
          :poll_participation,
          author:      new_person,
          poll_answer: FactoryBot.create(:poll_participation, author: old_person).poll_answer
        )
      end

      it "runs without errors" do
        expect {
          account_migration.perform!
        }.not_to raise_error
        expect(new_person.likes.count).to eq(1)
        expect(new_person.participations.count).to eq(1)
        expect(new_person.poll_participations.count).to eq(1)
        expect(new_person.contacts.count).to eq(1)
      end
    end

    context "with local account merging (non-empty new user)" do
      let(:old_user) { FactoryBot.create(:user) }
      let(:old_person) { old_user.person }
      let(:new_user) { FactoryBot.create(:user) }
      let(:new_person) { new_user.person }

      before do
        FactoryBot.create(
          :aspect,
          user: new_user,
          name: FactoryBot.create(:aspect, user: old_user).name
        )
        FactoryBot.create(
          :contact,
          user:   new_user,
          person: FactoryBot.create(:contact, user: old_user).person
        )
        FactoryBot.create(
          :tag_following,
          user: new_user,
          tag:  FactoryBot.create(:tag_following, user: old_user).tag
        )
      end

      it "runs without errors" do
        expect {
          account_migration.perform!
        }.not_to raise_error
        expect(new_user.contacts.count).to eq(1)
        expect(new_user.aspects.count).to eq(1)
      end
    end
  end

  describe "#newest_person" do
    let!(:second_migration) {
      FactoryBot.create(:account_migration, old_person: account_migration.new_person)
    }

    it "returns the newest account in the migration chain" do
      expect(account_migration.newest_person).to eq(second_migration.new_person)
    end
  end
end
