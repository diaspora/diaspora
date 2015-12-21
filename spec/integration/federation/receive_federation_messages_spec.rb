require "spec_helper"
require "diaspora_federation/test"
require "integration/federation/federation_helper"
require "integration/federation/federation_messages_generation"
require "integration/federation/shared_receive_relayable"
require "integration/federation/shared_receive_retraction"
require "integration/federation/shared_receive_stream_items"

def post_private_message(recipient_guid, xml)
  inlined_jobs do
    post "/receive/users/#{recipient_guid}", guid: recipient_guid, xml: xml
  end
end

def post_public_message(xml)
  inlined_jobs do
    post "/receive/public", xml: xml
  end
end

def post_message(recipient_guid, xml)
  if @public
    post_public_message(xml)
  else
    post_private_message(recipient_guid, xml)
  end
end

def set_up_sharing
  contact = alice.contacts.find_or_initialize_by(person_id: remote_user_on_pod_b.person.id)
  contact.sharing = true
  contact.save
end

describe "Receive federation messages feature" do
  before do
    allow(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(:queue_public_receive, any_args).and_call_original
    allow(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(:queue_private_receive, any_args).and_call_original
    allow(DiasporaFederation.callbacks).to receive(:trigger)
                                            .with(:save_person_after_webfinger, any_args).and_call_original
  end

  context "with public receive" do
    before do
      @public = true
    end

    it "receives account deletion correctly" do
      post_public_message(
        generate_xml(
          DiasporaFederation::Entities::AccountDeletion.new(diaspora_id: remote_user_on_pod_b.diaspora_handle),
          remote_user_on_pod_b,
          nil
        )
      )

      expect(AccountDeletion.where(diaspora_handle: remote_user_on_pod_b.diaspora_handle).exists?).to be(true)
    end

    it "rejects account deletion with wrong diaspora_id" do
      delete_id = FactoryGirl.generate(:diaspora_id)
      post_public_message(
        generate_xml(
          DiasporaFederation::Entities::AccountDeletion.new(diaspora_id: delete_id),
          remote_user_on_pod_b,
          nil
        )
      )

      expect(AccountDeletion.where(diaspora_handle: delete_id).exists?).to be(false)
      expect(AccountDeletion.where(diaspora_handle: remote_user_on_pod_b.diaspora_handle).exists?).to be(false)
    end

    it "reshare of public post passes" do
      @local_target = FactoryGirl.create(:status_message, author: alice.person, public: true)
      post_public_message(generate_reshare)

      expect(
        Reshare.where(root_guid: @local_target.guid, diaspora_handle: remote_user_on_pod_b.diaspora_handle).first
      ).not_to be_nil
    end

    it "reshare of private post fails" do
      @local_target = FactoryGirl.create(:status_message, author: alice.person, public: false)
      post_public_message(generate_reshare)

      expect(
        Reshare.where(root_guid: @local_target.guid, diaspora_handle: remote_user_on_pod_b.diaspora_handle).first
      ).to be_nil
    end

    it_behaves_like "messages which are indifferent about sharing fact"

    context "with sharing" do
      before do
        set_up_sharing
      end

      it_behaves_like "messages which are indifferent about sharing fact"
      it_behaves_like "messages which can't be send without sharing"
    end
  end

  context "with private receive" do
    before do
      @public = false
    end

    it "treats sharing request recive correctly" do
      entity = FactoryGirl.build(:request_entity, recipient_id: alice.diaspora_handle)

      expect(Diaspora::Fetcher::Public).to receive(:queue_for).exactly(1).times

      post_private_message(alice.guid, generate_xml(entity, remote_user_on_pod_b, alice))

      expect(alice.contacts.count).to eq(2)
      new_contact = alice.contacts.order(created_at: :asc).last
      expect(new_contact).not_to be_nil
      expect(new_contact.sharing).to eq(true)
      expect(new_contact.person.diaspora_handle).to eq(remote_user_on_pod_b.diaspora_handle)

      expect(
        Notifications::StartedSharing.where(
          recipient_id: alice.id,
          target_type:  "Person",
          target_id:    remote_user_on_pod_b.person.id
        ).first
      ).not_to be_nil
    end

    it "doesn't save the private status message if there is no sharing" do
      post_private_message(alice.guid, generate_status_message)

      expect(StatusMessage.exists?(guid: @entity.guid)).to be(false)
    end

    context "with sharing" do
      before do
        set_up_sharing
      end

      it_behaves_like "messages which are indifferent about sharing fact"
      it_behaves_like "messages which can't be send without sharing"

      it "treats profile receive correctly" do
        post_private_message(alice.guid, generate_profile)

        expect(Profile.where(diaspora_handle: @entity.diaspora_id).exists?).to be(true)
      end

      it "receives conversation correctly" do
        post_private_message(alice.guid, generate_conversation)

        expect(Conversation.exists?(guid: @entity.guid)).to be(true)
      end

      context "with message" do
        before do
          @local_target = FactoryGirl.build(:conversation, author: alice.person)
          @local_target.participants << remote_user_on_pod_b.person
          @local_target.participants << remote_user_on_pod_c.person
          @local_target.save
          @remote_target = FactoryGirl.build(:conversation, author: remote_user_on_pod_b.person)
          @remote_target.participants << alice.person
          @remote_target.participants << remote_user_on_pod_c.person
          @remote_target.save
        end

        it_behaves_like "it deals correctly with a relayable" do
          let(:entity_name) { :message_entity }
          let(:klass) { Message }
        end
      end
    end
  end
end
