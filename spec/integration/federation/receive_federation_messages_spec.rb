require "integration/federation/federation_helper"
require "integration/federation/shared_receive_relayable"
require "integration/federation/shared_receive_retraction"
require "integration/federation/shared_receive_stream_items"

describe "Receive federation messages feature" do
  before do
    allow_callbacks(%i(queue_public_receive queue_private_receive receive_entity fetch_related_entity))
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
          :reshare_entity, root_author: alice.diaspora_handle, root_guid: post.guid, author: sender_id)

        expect(Participation::Generator).to receive(:new).with(
          alice, instance_of(Reshare)
        ).and_return(double(create!: true))

        post_message(generate_xml(reshare, sender))

        expect(Reshare.exists?(root_guid: post.guid)).to be_truthy
        expect(Reshare.where(root_guid: post.guid).last.diaspora_handle).to eq(sender_id)
      end

      it "reshare of private post fails" do
        post = FactoryGirl.create(:status_message, author: alice.person, public: false)
        reshare = FactoryGirl.build(
          :reshare_entity, root_author: alice.diaspora_handle, root_guid: post.guid, author: sender_id)
        expect {
          post_message(generate_xml(reshare, sender))
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

    it "treats sharing request recive correctly" do
      entity = FactoryGirl.build(:request_entity, author: sender_id, recipient: alice.diaspora_handle)

      expect(Workers::ReceiveLocal).to receive(:perform_async).and_call_original

      post_message(generate_xml(entity, sender, alice), alice)

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
        entity = FactoryGirl.build(:profile_entity, author: sender_id)
        post_message(generate_xml(entity, sender, alice), alice)

        received_profile = sender.profile.reload

        expect(received_profile.first_name).to eq(entity.first_name)
        expect(received_profile.bio).to eq(entity.bio)
      end

      it "receives conversation correctly" do
        entity = FactoryGirl.build(
          :conversation_entity,
          author:       sender_id,
          participants: "#{sender_id};#{alice.diaspora_handle}"
        )
        post_message(generate_xml(entity, sender, alice), alice)

        expect(Conversation.exists?(guid: entity.guid)).to be_truthy
      end

      context "with message" do
        let(:local_parent) {
          FactoryGirl.build(:conversation, author: alice.person).tap do |target|
            target.participants << remote_user_on_pod_b.person
            target.participants << remote_user_on_pod_c.person
            target.save
          end
        }
        let(:remote_parent) {
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
