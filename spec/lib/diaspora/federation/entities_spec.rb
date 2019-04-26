# frozen_string_literal: true

describe Diaspora::Federation::Entities do
  describe ".build" do
    it "builds an account deletion" do
      diaspora_entity = FactoryGirl.build(:account_deletion)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::AccountDeletion)
      expect(federation_entity.author).to eq(diaspora_entity.person.diaspora_handle)
    end

    it "builds an account migration" do
      diaspora_entity = FactoryGirl.build(:account_migration)
      diaspora_entity.old_private_key = OpenSSL::PKey::RSA.generate(1024).export
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::AccountMigration)
      expect(federation_entity.author).to eq(diaspora_entity.old_person.diaspora_handle)
      expect(federation_entity.profile.author).to eq(diaspora_entity.new_person.diaspora_handle)
    end

    it "builds a comment" do
      diaspora_entity = FactoryGirl.build(:comment)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Comment)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.parent_guid).to eq(diaspora_entity.post.guid)
      expect(federation_entity.text).to eq(diaspora_entity.text)
      expect(federation_entity.created_at).to eq(diaspora_entity.created_at)
      expect(federation_entity.author_signature).to be_nil
      expect(federation_entity.additional_data).to be_empty
    end

    it "builds a comment with signature" do
      diaspora_entity = FactoryGirl.build(:comment, signature: FactoryGirl.build(:comment_signature))
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Comment)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.parent_guid).to eq(diaspora_entity.post.guid)
      expect(federation_entity.text).to eq(diaspora_entity.text)
      expect(federation_entity.created_at).to eq(diaspora_entity.created_at)
      expect(federation_entity.author_signature).to eq(diaspora_entity.signature.author_signature)
      expect(federation_entity.signature_order.map(&:to_s)).to eq(diaspora_entity.signature.signature_order.order.split)
      expect(federation_entity.additional_data).to eq(diaspora_entity.signature.additional_data)
    end

    it "builds a comment with edited_at" do
      edited_at = Time.now.utc + 3600
      diaspora_entity = FactoryGirl.build(
        :comment,
        signature: FactoryGirl.build(:comment_signature, additional_data: {"edited_at" => edited_at})
      )
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Comment)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.parent_guid).to eq(diaspora_entity.post.guid)
      expect(federation_entity.text).to eq(diaspora_entity.text)
      expect(federation_entity.created_at).to eq(diaspora_entity.created_at)
      expect(federation_entity.edited_at).to be_within(1.second).of(edited_at)
      expect(federation_entity.author_signature).to eq(diaspora_entity.signature.author_signature)
      expect(federation_entity.signature_order.map(&:to_s)).to eq(diaspora_entity.signature.signature_order.order.split)
      expect(federation_entity.additional_data).to eq(diaspora_entity.signature.additional_data)
    end

    it "builds a contact" do
      diaspora_entity = FactoryGirl.build(:contact, receiving: true)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Contact)
      expect(federation_entity.author).to eq(diaspora_entity.user.diaspora_handle)
      expect(federation_entity.recipient).to eq(diaspora_entity.person.diaspora_handle)
      expect(federation_entity.sharing).to be_truthy
      expect(federation_entity.following).to be_truthy
      expect(federation_entity.blocking).to be_falsey
    end

    it "builds a contact for a block" do
      diaspora_entity = FactoryGirl.create(:block)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Contact)
      expect(federation_entity.author).to eq(diaspora_entity.user.diaspora_handle)
      expect(federation_entity.recipient).to eq(diaspora_entity.person.diaspora_handle)
      expect(federation_entity.sharing).to be_falsey
      expect(federation_entity.following).to be_falsey
      expect(federation_entity.blocking).to be_truthy
    end

    context "Conversation" do
      let(:participant) { FactoryGirl.create(:person) }
      let(:diaspora_entity) { FactoryGirl.create(:conversation_with_message, participants: [participant]) }
      let(:federation_entity) { described_class.build(diaspora_entity) }

      it "builds a conversation" do
        expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Conversation)
        expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
        expect(federation_entity.guid).to eq(diaspora_entity.guid)
        expect(federation_entity.subject).to eq(diaspora_entity.subject)
        expect(federation_entity.created_at).to eq(diaspora_entity.created_at)
      end

      it "adds the participants" do
        expect(federation_entity.participants)
          .to eq("#{participant.diaspora_handle};#{diaspora_entity.author.diaspora_handle}")
      end

      it "includes the message" do
        diaspora_message = diaspora_entity.messages.first
        federation_message = federation_entity.messages.first

        expect(federation_message.author).to eq(diaspora_message.author.diaspora_handle)
        expect(federation_message.guid).to eq(diaspora_message.guid)
        expect(federation_message.conversation_guid).to eq(diaspora_entity.guid)
        expect(federation_message.text).to eq(diaspora_message.text)
        expect(federation_message.created_at).to eq(diaspora_message.created_at)
      end
    end

    it "builds a like" do
      diaspora_entity = FactoryGirl.build(:like)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Like)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.parent_guid).to eq(diaspora_entity.target.guid)
      expect(federation_entity.positive).to eq(diaspora_entity.positive)
      expect(federation_entity.author_signature).to be_nil
      expect(federation_entity.additional_data).to be_empty
    end

    it "builds a like with signature" do
      diaspora_entity = FactoryGirl.build(:like, signature: FactoryGirl.build(:like_signature))
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Like)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.parent_guid).to eq(diaspora_entity.target.guid)
      expect(federation_entity.positive).to eq(diaspora_entity.positive)
      expect(federation_entity.author_signature).to eq(diaspora_entity.signature.author_signature)
      expect(federation_entity.signature_order.map(&:to_s)).to eq(diaspora_entity.signature.signature_order.order.split)
      expect(federation_entity.additional_data).to eq(diaspora_entity.signature.additional_data)
    end

    it "builds a message" do
      diaspora_entity = FactoryGirl.create(:message)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Message)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.conversation_guid).to eq(diaspora_entity.conversation.guid)
      expect(federation_entity.text).to eq(diaspora_entity.text)
      expect(federation_entity.created_at).to eq(diaspora_entity.created_at)
    end

    it "builds a participation" do
      diaspora_entity = FactoryGirl.build(:participation)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Participation)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.parent_guid).to eq(diaspora_entity.target.guid)
      expect(federation_entity.parent_type).to eq(diaspora_entity.target.class.base_class.to_s)
    end

    it "builds a photo" do
      diaspora_entity = FactoryGirl.create(:photo)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Photo)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.public).to eq(diaspora_entity.public)
      expect(federation_entity.created_at).to eq(diaspora_entity.created_at)
      expect(federation_entity.remote_photo_path).to eq(diaspora_entity.remote_photo_path)
      expect(federation_entity.remote_photo_name).to eq(diaspora_entity.remote_photo_name)
      expect(federation_entity.text).to eq(diaspora_entity.text)
      expect(federation_entity.height).to eq(diaspora_entity.height)
      expect(federation_entity.width).to eq(diaspora_entity.width)
    end

    it "builds a poll participation" do
      diaspora_entity = FactoryGirl.build(:poll_participation)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::PollParticipation)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.parent_guid).to eq(diaspora_entity.poll_answer.poll.guid)
      expect(federation_entity.poll_answer_guid).to eq(diaspora_entity.poll_answer.guid)
      expect(federation_entity.author_signature).to be_nil
      expect(federation_entity.additional_data).to be_empty
    end

    it "builds a poll participation with signature" do
      signature = FactoryGirl.build(:poll_participation_signature)
      diaspora_entity = FactoryGirl.build(:poll_participation, signature: signature)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::PollParticipation)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.parent_guid).to eq(diaspora_entity.poll_answer.poll.guid)
      expect(federation_entity.poll_answer_guid).to eq(diaspora_entity.poll_answer.guid)
      expect(federation_entity.author_signature).to eq(signature.author_signature)
      expect(federation_entity.signature_order.map(&:to_s)).to eq(signature.signature_order.order.split)
      expect(federation_entity.additional_data).to eq(signature.additional_data)
    end

    it "builds a profile" do
      diaspora_entity = FactoryGirl.build(:profile_with_image_url)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Profile)
      expect(federation_entity.author).to eq(diaspora_entity.diaspora_handle)
      expect(federation_entity.edited_at).to eq(diaspora_entity.updated_at)
      expect(federation_entity.first_name).to eq(diaspora_entity.first_name)
      expect(federation_entity.last_name).to eq(diaspora_entity.last_name)
      expect(federation_entity.image_url).to eq(diaspora_entity.image_url)
      expect(federation_entity.image_url_medium).to eq(diaspora_entity.image_url_medium)
      expect(federation_entity.image_url_small).to eq(diaspora_entity.image_url_small)
      expect(federation_entity.birthday).to eq(diaspora_entity.birthday)
      expect(federation_entity.gender).to eq(diaspora_entity.gender)
      expect(federation_entity.bio).to eq(diaspora_entity.bio)
      expect(federation_entity.location).to eq(diaspora_entity.location)
      expect(federation_entity.searchable).to eq(diaspora_entity.searchable)
      expect(federation_entity.nsfw).to eq(diaspora_entity.nsfw)
      expect(federation_entity.tag_string.split(" ")).to match_array(diaspora_entity.tag_string.split(" "))
      expect(federation_entity.public).to eq(diaspora_entity.public_details)
    end

    it "builds a reshare" do
      diaspora_entity = FactoryGirl.create(:reshare)
      federation_entity = described_class.build(diaspora_entity)

      expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Reshare)
      expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
      expect(federation_entity.guid).to eq(diaspora_entity.guid)
      expect(federation_entity.root_author).to eq(diaspora_entity.root.author.diaspora_handle)
      expect(federation_entity.root_guid).to eq(diaspora_entity.root.guid)
      expect(federation_entity.created_at).to eq(diaspora_entity.created_at)
    end

    context "Retraction" do
      it "builds a Retraction entity for a Photo retraction" do
        target = FactoryGirl.create(:photo, author: alice.person)
        retraction = Retraction.for(target)
        federation_entity = described_class.build(retraction)

        expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Retraction)
        expect(federation_entity.author).to eq(target.author.diaspora_handle)
        expect(federation_entity.target_guid).to eq(target.guid)
        expect(federation_entity.target_type).to eq("Photo")
      end

      it "builds a Contact for a Contact retraction" do
        target = FactoryGirl.create(:contact, receiving: false)
        retraction = ContactRetraction.for(target)
        federation_entity = described_class.build(retraction)

        expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Contact)
        expect(federation_entity.author).to eq(target.user.diaspora_handle)
        expect(federation_entity.recipient).to eq(target.person.diaspora_handle)
        expect(federation_entity.sharing).to be_falsey
        expect(federation_entity.following).to be_falsey
        expect(federation_entity.blocking).to be_falsey
      end

      it "builds a Contact for a Contact retraction with block" do
        target = FactoryGirl.create(:contact, receiving: false)
        FactoryGirl.create(:block, user: target.user, person: target.person)
        retraction = ContactRetraction.for(target)
        federation_entity = described_class.build(retraction)

        expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Contact)
        expect(federation_entity.author).to eq(target.user.diaspora_handle)
        expect(federation_entity.recipient).to eq(target.person.diaspora_handle)
        expect(federation_entity.sharing).to be_falsey
        expect(federation_entity.following).to be_falsey
        expect(federation_entity.blocking).to be_truthy
      end

      it "builds a Contact for a Block retraction" do
        target = FactoryGirl.create(:block)
        target.delete
        retraction = ContactRetraction.for(target)
        federation_entity = described_class.build(retraction)

        expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::Contact)
        expect(federation_entity.author).to eq(target.user.diaspora_handle)
        expect(federation_entity.recipient).to eq(target.person.diaspora_handle)
        expect(federation_entity.sharing).to be_falsey
        expect(federation_entity.following).to be_falsey
        expect(federation_entity.blocking).to be_falsey
      end
    end

    context "StatusMessage" do
      it "builds a status message" do
        diaspora_entity = FactoryGirl.create(:status_message)
        federation_entity = described_class.build(diaspora_entity)

        expect(federation_entity).to be_instance_of(DiasporaFederation::Entities::StatusMessage)
        expect(federation_entity.author).to eq(diaspora_entity.author.diaspora_handle)
        expect(federation_entity.guid).to eq(diaspora_entity.guid)
        expect(federation_entity.text).to eq(diaspora_entity.text)
        expect(federation_entity.public).to eq(diaspora_entity.public)
        expect(federation_entity.created_at).to eq(diaspora_entity.created_at)
        expect(federation_entity.provider_display_name).to eq(diaspora_entity.provider_display_name)

        expect(federation_entity.photos).to be_empty
        expect(federation_entity.location).to be_nil
        expect(federation_entity.poll).to be_nil
      end

      it "includes the photos" do
        diaspora_entity = FactoryGirl.create(:status_message_with_photo)
        diaspora_photo = diaspora_entity.photos.first
        federation_entity = described_class.build(diaspora_entity)
        federation_photo = federation_entity.photos.first

        expect(federation_entity.photos.size).to eq(1)
        expect(federation_photo.author).to eq(diaspora_entity.author.diaspora_handle)
        expect(federation_photo.guid).to eq(diaspora_photo.guid)
        expect(federation_photo.public).to eq(diaspora_photo.public)
        expect(federation_photo.created_at).to eq(diaspora_photo.created_at)
        expect(federation_photo.remote_photo_path).to eq(diaspora_photo.remote_photo_path)
        expect(federation_photo.remote_photo_name).to eq(diaspora_photo.remote_photo_name)
        expect(federation_photo.text).to eq(diaspora_photo.text)
        expect(federation_photo.height).to eq(diaspora_photo.height)
        expect(federation_photo.width).to eq(diaspora_photo.width)
      end

      it "includes the location" do
        diaspora_entity = FactoryGirl.create(:status_message_with_location)
        diaspora_location = diaspora_entity.location
        federation_entity = described_class.build(diaspora_entity)
        federation_location = federation_entity.location

        expect(federation_location.address).to eq(diaspora_location.address)
        expect(federation_location.lat).to eq(diaspora_location.lat)
        expect(federation_location.lng).to eq(diaspora_location.lng)
      end

      it "includes the poll" do
        diaspora_entity = FactoryGirl.create(:status_message_with_poll)
        diaspora_poll = diaspora_entity.poll
        federation_entity = described_class.build(diaspora_entity)
        federation_poll = federation_entity.poll

        expect(federation_poll.guid).to eq(diaspora_poll.guid)
        expect(federation_poll.question).to eq(diaspora_poll.question)

        diaspora_answer1 = diaspora_poll.poll_answers.first
        diaspora_answer2 = diaspora_poll.poll_answers.second
        federation_answer1 = federation_poll.poll_answers.first
        federation_answer2 = federation_poll.poll_answers.second

        expect(federation_answer1.guid).to eq(diaspora_answer1.guid)
        expect(federation_answer1.answer).to eq(diaspora_answer1.answer)
        expect(federation_answer2.guid).to eq(diaspora_answer2.guid)
        expect(federation_answer2.answer).to eq(diaspora_answer2.answer)
      end
    end
  end
end
