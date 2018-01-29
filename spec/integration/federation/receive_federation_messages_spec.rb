# frozen_string_literal: true

require "integration/federation/federation_helper"
require "integration/federation/shared_receive_relayable"
require "integration/federation/shared_receive_retraction"
require "integration/federation/shared_receive_stream_items"

describe "Receive federation messages feature" do
  before do
    allow_callbacks(%i(queue_public_receive queue_private_receive receive_entity fetch_related_entity))
  end

  let(:sender) { remote_user_on_pod_b }
  let(:sender_id) { sender.diaspora_handle }

  context "with public receive" do
    let(:recipient) { nil }

    context "account deletion" do
      it "receives account deletion correctly" do
        post_message(generate_payload(DiasporaFederation::Entities::AccountDeletion.new(author: sender_id), sender))

        expect(AccountDeletion.exists?(person: sender.person)).to be_truthy
      end

      it "rejects account deletion with wrong author" do
        delete_id = Fabricate.sequence(:diaspora_id)
        expect {
          post_message(generate_payload(DiasporaFederation::Entities::AccountDeletion.new(author: delete_id), sender))
        }.not_to change(AccountDeletion, :count)
      end
    end

    context "account migration" do
      # In case when sender is unknown we should just ignore the migration
      # but this depends on https://github.com/diaspora/diaspora_federation/issues/72
      # which is low-priority, so we just discover the sender profile in this case.
      # But there won't be a spec for that.

      let(:entity) { create_account_migration_entity(sender_id, new_user) }

      def run_migration
        post_message(generate_payload(entity, sender))
      end

      context "with undiscovered new user profile" do
        before do
          allow_callbacks(%i[fetch_public_key])
          allow_private_key_fetch(new_user)
          expect_person_discovery(new_user)
        end

        let(:new_user) { create_undiscovered_user("example.org") }

        it "receives account migration correctly" do
          run_migration
          expect(AccountMigration.where(old_person: sender.person, new_person: new_user.person)).to exist
          expect(AccountMigration.find_by(old_person: sender.person, new_person: new_user.person)).to be_performed
        end

        it "doesn't run the same migration for the second time" do
          run_migration
          expect_any_instance_of(AccountMigration).not_to receive(:perform!)
          run_migration
          expect(AccountMigration.where(old_person: sender.person, new_person: new_user.person).count).to eq(1)
          expect(AccountMigration.find_by(old_person: sender.person, new_person: new_user.person)).to be_performed
        end

        it "doesn't accept second migration for the same sender" do
          run_migration
          expect {
            entity = create_account_migration_entity(sender_id, create_remote_user("example.org"))
            post_message(generate_payload(entity, sender))
          }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it "doesn't accept second migration for the same new user profile" do
          run_migration
          expect {
            sender = create_remote_user("example.org")
            entity = create_account_migration_entity(sender.diaspora_handle, new_user)
            post_message(generate_payload(entity, sender))
          }.to raise_error(ActiveRecord::RecordInvalid)
        end

        context "when our pod was left" do
          let(:sender) { FactoryGirl.create(:user) }

          it "locks the old user account access" do
            run_migration
            expect(sender.reload.access_locked?).to be_truthy
          end
        end
      end

      context "with discovered profile" do
        let(:new_user) { create_remote_user("example.org") }

        it "updates person profile with data from entity" do
          new_user.profile.bio = "my updated biography"
          expect(entity.profile.bio).to eq("my updated biography")
          expect(new_user.profile.reload.bio).not_to eq("my updated biography")
          run_migration
          expect(new_user.profile.reload.bio).to eq("my updated biography")
        end
      end
    end

    context "reshare" do
      it "reshare of public post passes" do
        post = FactoryGirl.create(:status_message, author: alice.person, public: true)
        reshare = Fabricate(
          :reshare_entity, root_author: alice.diaspora_handle, root_guid: post.guid, author: sender_id)

        expect(Participation::Generator).to receive(:new).with(
          alice, instance_of(Reshare)
        ).and_return(double(create!: true))

        expect(Diaspora::Federation::Dispatcher).to receive(:build) do |_user, participation, _opts|
          expect(participation.target.guid).to eq(reshare.guid)
          instance_double(:dispatch)
        end

        post_message(generate_payload(reshare, sender))

        expect(Reshare.exists?(root_guid: post.guid)).to be_truthy
        expect(Reshare.where(root_guid: post.guid).last.diaspora_handle).to eq(sender_id)
      end

      it "reshare of private post fails" do
        post = FactoryGirl.create(:status_message, author: alice.person, public: false)
        reshare = Fabricate(
          :reshare_entity, root_author: alice.diaspora_handle, root_guid: post.guid, author: sender_id)
        expect {
          post_message(generate_payload(reshare, sender))
        }.to raise_error ActiveRecord::RecordInvalid, "Validation failed: Only posts which are public may be reshared."

        expect(Reshare.exists?(root_guid: post.guid)).to be_falsey
      end
    end

    it_behaves_like "messages which are indifferent about sharing fact"

    context "with sharing" do
      before do
        contact = alice.contacts.find_or_initialize_by(person_id: sender.person.id)
        contact.sharing = true
        contact.save
      end

      it_behaves_like "messages which are indifferent about sharing fact"
      it_behaves_like "messages which can't be send without sharing"
    end
  end

  context "with private receive" do
    let(:recipient) { alice }

    it "treats sharing request receive correctly" do
      entity = Fabricate(:contact_entity, author: sender_id, recipient: alice.diaspora_handle)

      expect(Workers::ReceiveLocal).to receive(:perform_async).and_call_original

      post_message(generate_payload(entity, sender, alice), alice)

      expect(alice.contacts.count).to eq(2)
      new_contact = alice.contacts.find {|c| c.person.diaspora_handle == sender_id }
      expect(new_contact).not_to be_nil
      expect(new_contact.sharing).to eq(true)

      expect(
        Notifications::StartedSharing.exists?(
          recipient_id: alice.id,
          target_type:  "Person",
          target_id:    sender.person.id
        )
      ).to be_truthy
    end

    context "with sharing" do
      before do
        contact = alice.contacts.find_or_initialize_by(person_id: sender.person.id)
        contact.sharing = true
        contact.save
      end

      it_behaves_like "messages which are indifferent about sharing fact"
      it_behaves_like "messages which can't be send without sharing"

      it "treats profile receive correctly" do
        entity = Fabricate(:profile_entity, author: sender_id)
        post_message(generate_payload(entity, sender, alice), alice)

        received_profile = sender.profile.reload

        expect(received_profile.first_name).to eq(entity.first_name)
        expect(received_profile.bio).to eq(entity.bio)
      end

      it "receives conversation correctly" do
        entity = Fabricate(
          :conversation_entity,
          author:       sender_id,
          participants: "#{sender_id};#{alice.diaspora_handle}"
        )
        post_message(generate_payload(entity, sender, alice), alice)

        expect(Conversation.exists?(guid: entity.guid)).to be_truthy
      end

      context "with message" do
        context "local" do
          let(:parent) {
            FactoryGirl.build(:conversation, author: alice.person).tap do |target|
              target.participants << remote_user_on_pod_b.person
              target.participants << remote_user_on_pod_c.person
              target.save
            end
          }
          let(:message) {
            Fabricate(
              :message_entity,
              conversation_guid: parent.guid,
              author:            sender_id,
              parent:            Diaspora::Federation::Entities.related_entity(parent)
            )
          }

          it "receives the message correctly" do
            expect(Workers::ReceiveLocal).to receive(:perform_async)
            post_message(generate_payload(message, sender, recipient), recipient)

            received_message = Message.find_by(guid: message.guid)
            expect(received_message).not_to be_nil
            expect(received_message.author.diaspora_handle).to eq(sender_id)
          end
        end

        context "remote" do
          let(:parent) {
            FactoryGirl.build(:conversation, author: remote_user_on_pod_b.person).tap do |target|
              target.participants << alice.person
              target.participants << remote_user_on_pod_c.person
              target.save
            end
          }
          let(:message) {
            Fabricate(
              :message_entity,
              conversation_guid: parent.guid,
              author:            remote_user_on_pod_c.diaspora_handle,
              parent:            Diaspora::Federation::Entities.related_entity(parent)
            )
          }

          it "receives the message correctly" do
            expect(Workers::ReceiveLocal).to receive(:perform_async)
            post_message(generate_payload(message, remote_user_on_pod_c, recipient), recipient)

            received_message = Message.find_by(guid: message.guid)
            expect(received_message).not_to be_nil
            expect(received_message.author.diaspora_handle).to eq(remote_user_on_pod_c.diaspora_handle)
          end
        end
      end
    end
  end
end
