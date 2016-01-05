require "spec_helper"
require "integration/federation/federation_helper"
require "integration/federation/shared_receive_relayable"
require "integration/federation/shared_receive_retraction"
require "integration/federation/shared_receive_stream_items"

describe "Receive federation messages feature" do
  before do
    allow(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(:queue_public_receive, any_args).and_call_original
    allow(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(:queue_private_receive, any_args).and_call_original
  end

  let(:sender) { remote_user_on_pod_b }
  let(:sender_id) { remote_user_on_pod_b.diaspora_handle }

  context "with public receive" do
    let(:recipient) { nil }

    it "receives account deletion correctly" do
      post_message(generate_xml(DiasporaFederation::Entities::AccountDeletion.new(diaspora_id: sender_id), sender))

      expect(AccountDeletion.exists?(diaspora_handle: sender_id)).to be_truthy
    end

    it "rejects account deletion with wrong diaspora_id" do
      delete_id = FactoryGirl.generate(:diaspora_id)
      post_message(generate_xml(DiasporaFederation::Entities::AccountDeletion.new(diaspora_id: delete_id), sender))

      expect(AccountDeletion.exists?(diaspora_handle: delete_id)).to be_falsey
      expect(AccountDeletion.exists?(diaspora_handle: sender_id)).to be_falsey
    end

    context "reshare" do
      it "reshare of public post passes" do
        post = FactoryGirl.create(:status_message, author: alice.person, public: true)
        reshare = FactoryGirl.build(
          :reshare_entity, root_diaspora_id: alice.diaspora_handle, root_guid: post.guid, diaspora_id: sender_id)
        post_message(generate_xml(reshare, sender))

        expect(Reshare.exists?(root_guid: post.guid, diaspora_handle: sender_id)).to be_truthy
      end

      it "reshare of private post fails" do
        post = FactoryGirl.create(:status_message, author: alice.person, public: false)
        reshare = FactoryGirl.build(
          :reshare_entity, root_diaspora_id: alice.diaspora_handle, root_guid: post.guid, diaspora_id: sender_id)
        post_message(generate_xml(reshare, sender))

        expect(Reshare.exists?(root_guid: post.guid, diaspora_handle: sender_id)).to be_falsey
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

    it "treats sharing request recive correctly" do
      entity = FactoryGirl.build(:request_entity, recipient_id: alice.diaspora_handle)

      expect(Diaspora::Fetcher::Public).to receive(:queue_for).exactly(1).times

      post_message(generate_xml(entity, sender, alice), alice)

      expect(alice.contacts.count).to eq(2)
      new_contact = alice.contacts.order(created_at: :asc).last
      expect(new_contact).not_to be_nil
      expect(new_contact.sharing).to eq(true)
      expect(new_contact.person.diaspora_handle).to eq(sender_id)

      expect(
        Notifications::StartedSharing.exists?(
          recipient_id: alice.id,
          target_type:  "Person",
          target_id:    sender.person.id
        )
      ).to be_truthy
    end

    it "doesn't save the private status message if there is no sharing" do
      entity = FactoryGirl.build(:status_message_entity, diaspora_id: sender_id, public: false)
      post_message(generate_xml(entity, sender, alice), alice)

      expect(StatusMessage.exists?(guid: entity.guid)).to be_falsey
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
        entity = FactoryGirl.build(:profile_entity, diaspora_id: sender_id)
        post_message(generate_xml(entity, sender, alice), alice)

        expect(Profile.exists?(diaspora_handle: entity.diaspora_id)).to be_truthy
      end

      it "receives conversation correctly" do
        entity = FactoryGirl.build(
          :conversation_entity,
          diaspora_id:     sender_id,
          participant_ids: "#{sender_id};#{alice.diaspora_handle}"
        )
        post_message(generate_xml(entity, sender, alice), alice)

        expect(Conversation.exists?(guid: entity.guid)).to be_truthy
      end

      context "with message" do
        let(:local_target) {
          FactoryGirl.build(:conversation, author: alice.person).tap do |target|
            target.participants << remote_user_on_pod_b.person
            target.participants << remote_user_on_pod_c.person
            target.save
          end
        }
        let(:remote_target) {
          FactoryGirl.build(:conversation, author: remote_user_on_pod_b.person).tap do |target|
            target.participants << alice.person
            target.participants << remote_user_on_pod_c.person
            target.save
          end
        }
        let(:entity_name) { :message_entity }
        let(:klass) { Message }

        it_behaves_like "it deals correctly with a relayable"
      end
    end
  end
end
