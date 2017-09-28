# frozen_string_literal: true

describe Diaspora::Federation::Receive do
  let(:sender) { FactoryGirl.create(:person) }
  let(:post) { FactoryGirl.create(:status_message, text: "hello", public: true, author: alice.person) }

  describe ".account_deletion" do
    let(:account_deletion_entity) { Fabricate(:account_deletion_entity, author: sender.diaspora_handle) }

    it "saves the account deletion" do
      Diaspora::Federation::Receive.account_deletion(account_deletion_entity)

      expect(AccountDeletion.exists?(person: sender)).to be_truthy
    end
  end

  describe ".account_migration" do
    let(:new_person) { FactoryGirl.create(:person) }
    let(:profile_entity) { Fabricate(:profile_entity, author: new_person.diaspora_handle) }
    let(:account_migration_entity) {
      Fabricate(:account_migration_entity, author: sender.diaspora_handle, profile: profile_entity)
    }

    it "saves the account deletion" do
      Diaspora::Federation::Receive.account_migration(account_migration_entity)

      expect(AccountMigration.exists?(old_person: sender, new_person: new_person)).to be_truthy
    end
  end

  describe ".comment" do
    let(:comment_entity) {
      build_relayable_federation_entity(
        :comment,
        {
          author:           sender.diaspora_handle,
          parent_guid:      post.guid,
          author_signature: "aa"
        },
        "new_property" => "data"
      )
    }

    it "saves the comment" do
      received = Diaspora::Federation::Receive.perform(comment_entity)

      comment = Comment.find_by!(guid: comment_entity.guid)

      expect(received).to eq(comment)
      expect(comment.author).to eq(sender)
      expect(comment.text).to eq(comment_entity.text)
      expect(comment.created_at.iso8601).to eq(comment_entity.created_at.iso8601)
    end

    it "attaches the comment to the post" do
      Diaspora::Federation::Receive.perform(comment_entity)

      comment = Comment.find_by!(guid: comment_entity.guid)

      expect(post.comments).to include(comment)
      expect(comment.post).to eq(post)
    end

    it "saves the signature data" do
      Diaspora::Federation::Receive.perform(comment_entity)

      comment = Comment.find_by!(guid: comment_entity.guid)

      expect(comment.signature).not_to be_nil
      expect(comment.signature.author_signature).to eq("aa")
      expect(comment.signature.additional_data).to eq("new_property" => "data")
      expect(comment.signature.order).to eq(comment_entity.signature_order.map(&:to_s))
    end

    let(:entity) { comment_entity }
    it_behaves_like "it ignores existing object received twice", Comment
    it_behaves_like "it rejects if the root author ignores the author", Comment
    it_behaves_like "it relays relayables", Comment
  end

  describe ".contact" do
    let(:contact_entity) {
      Fabricate(:contact_entity, author: sender.diaspora_handle, recipient: alice.diaspora_handle)
    }

    it "creates the contact if it doesn't exist" do
      received = Diaspora::Federation::Receive.perform(contact_entity)

      contact = alice.contacts.find_by!(person_id: sender.id)

      expect(received).to eq(contact)
      expect(contact.sharing).to be_truthy
    end

    it "updates the contact if it exists" do
      alice.contacts.find_or_initialize_by(person_id: sender.id, receiving: true, sharing: false).save!

      received = Diaspora::Federation::Receive.perform(contact_entity)

      contact = alice.contacts.find_by!(person_id: sender.id)

      expect(received).to eq(contact)
      expect(contact.sharing).to be_truthy
    end

    it "does nothing, if already sharing" do
      alice.contacts.find_or_initialize_by(person_id: sender.id, receiving: true, sharing: true).save!

      expect_any_instance_of(Contact).not_to receive(:save!)

      expect(Diaspora::Federation::Receive.perform(contact_entity)).to be_nil
    end

    context "sharing=false" do
      let(:unshare_contact_entity) {
        Fabricate(
          :contact_entity,
          author:    sender.diaspora_handle,
          recipient: alice.diaspora_handle,
          sharing:   false
        )
      }

      it "disconnects, if currently connected" do
        alice.contacts.find_or_initialize_by(person_id: sender.id, receiving: true, sharing: true).save!

        received = Diaspora::Federation::Receive.perform(unshare_contact_entity)
        expect(received).to be_nil

        contact = alice.contacts.find_by!(person_id: sender.id)

        expect(contact).not_to be_nil
        expect(contact.sharing).to be_falsey
      end

      it "does nothing, if already disconnected" do
        received = Diaspora::Federation::Receive.perform(unshare_contact_entity)
        expect(received).to be_nil
        expect(alice.contacts.find_by(person_id: sender.id)).to be_nil
      end
    end
  end

  describe ".conversation" do
    let(:conv_guid) { Fabricate.sequence(:guid) }
    let(:message_entity) {
      Fabricate(
        :message_entity,
        author:            alice.diaspora_handle,
        parent_guid:       conv_guid,
        conversation_guid: conv_guid
      )
    }
    let(:conversation_entity) {
      Fabricate(
        :conversation_entity,
        guid:         conv_guid,
        author:       alice.diaspora_handle,
        messages:     [message_entity],
        participants: "#{alice.diaspora_handle};#{bob.diaspora_handle}"
      )
    }

    it "saves the conversation" do
      received = Diaspora::Federation::Receive.perform(conversation_entity)

      conv = Conversation.find_by!(guid: conversation_entity.guid)

      expect(received).to eq(conv)
      expect(conv.author).to eq(alice.person)
      expect(conv.subject).to eq(conversation_entity.subject)
    end

    it "saves the message" do
      Diaspora::Federation::Receive.perform(conversation_entity)

      conv = Conversation.find_by!(guid: conversation_entity.guid)

      expect(conv.messages.count).to eq(1)
      expect(conv.messages.first.author).to eq(alice.person)
      expect(conv.messages.first.text).to eq(message_entity.text)
      expect(conv.messages.first.created_at.iso8601).to eq(message_entity.created_at.iso8601)
    end

    it "creates appropriate visibilities" do
      Diaspora::Federation::Receive.perform(conversation_entity)

      conv = Conversation.find_by!(guid: conversation_entity.guid)

      expect(conv.participants.count).to eq(2)
      expect(conv.participants).to include(alice.person, bob.person)
    end

    it_behaves_like "it ignores existing object received twice", Conversation do
      let(:entity) { conversation_entity }
    end
  end

  describe ".like" do
    let(:like_entity) {
      build_relayable_federation_entity(
        :like,
        {
          author:           sender.diaspora_handle,
          parent_guid:      post.guid,
          author_signature: "aa"
        },
        "new_property" => "data"
      )
    }

    it "saves the like" do
      received = Diaspora::Federation::Receive.perform(like_entity)

      like = Like.find_by!(guid: like_entity.guid)

      expect(received).to eq(like)
      expect(like.author).to eq(sender)
      expect(like.positive).to be_truthy
    end

    it "attaches the like to the post" do
      Diaspora::Federation::Receive.perform(like_entity)

      like = Like.find_by!(guid: like_entity.guid)

      expect(post.likes).to include(like)
      expect(like.target).to eq(post)
    end

    it "saves the signature data" do
      Diaspora::Federation::Receive.perform(like_entity)

      like = Like.find_by!(guid: like_entity.guid)

      expect(like.signature).not_to be_nil
      expect(like.signature.author_signature).to eq("aa")
      expect(like.signature.additional_data).to eq("new_property" => "data")
      expect(like.signature.order).to eq(like_entity.signature_order.map(&:to_s))
    end

    let(:entity) { like_entity }
    it_behaves_like "it ignores existing object received twice", Like
    it_behaves_like "it rejects if the root author ignores the author", Like
    it_behaves_like "it relays relayables", Like

    context "like for a comment" do
      let(:comment) { FactoryGirl.create(:comment, post: post) }
      let(:like_entity) {
        build_relayable_federation_entity(
          :like,
          {
            author:           sender.diaspora_handle,
            parent_guid:      comment.guid,
            parent_type:      "Comment",
            author_signature: "aa"
          },
          "new_property" => "data"
        )
      }

      it "attaches the like to the comment" do
        Diaspora::Federation::Receive.perform(like_entity)

        like = Like.find_by!(guid: like_entity.guid)

        expect(comment.likes).to include(like)
        expect(like.target).to eq(comment)
      end

      it "saves the signature data" do
        Diaspora::Federation::Receive.perform(like_entity)

        like = Like.find_by!(guid: like_entity.guid)

        expect(like.signature).not_to be_nil
        expect(like.signature.author_signature).to eq("aa")
        expect(like.signature.additional_data).to eq("new_property" => "data")
        expect(like.signature.order).to eq(like_entity.signature_order.map(&:to_s))
      end

      let(:entity) { like_entity }
      it_behaves_like "it ignores existing object received twice", Like
      it_behaves_like "it rejects if the root author ignores the author", Like
      it_behaves_like "it relays relayables", Like
    end
  end

  describe ".message" do
    let(:conversation) {
      FactoryGirl.build(:conversation, author: alice.person).tap do |conv|
        conv.participants << sender
        conv.save!
      end
    }
    let(:message_entity) {
      Fabricate(
        :message_entity,
        author:            sender.diaspora_handle,
        parent_guid:       conversation.guid,
        conversation_guid: conversation.guid
      )
    }

    it "saves the message" do
      received = Diaspora::Federation::Receive.perform(message_entity)

      msg = Message.find_by!(guid: message_entity.guid)

      expect(received).to eq(msg)
      expect(msg.author).to eq(sender)
      expect(msg.text).to eq(message_entity.text)
      expect(msg.created_at.iso8601).to eq(message_entity.created_at.iso8601)
    end

    it "attaches the message to the conversation" do
      msg = Diaspora::Federation::Receive.perform(message_entity)

      conv = Conversation.find_by!(guid: conversation.guid)

      expect(conv.messages).to include(msg)
      expect(msg.conversation).to eq(conv)
    end

    let(:entity) { message_entity }
    it_behaves_like "it ignores existing object received twice", Message
  end

  describe ".participation" do
    let(:participation_entity) {
      Fabricate(:participation_entity, author: sender.diaspora_handle, parent_guid: post.guid)
    }

    it "saves the participation" do
      received = Diaspora::Federation::Receive.perform(participation_entity)

      participation = Participation.find_by!(guid: participation_entity.guid)

      expect(received).to eq(participation)
      expect(participation.author).to eq(sender)
    end

    it "attaches the participation to the post" do
      Diaspora::Federation::Receive.perform(participation_entity)

      participation = Participation.find_by!(guid: participation_entity.guid)

      expect(post.participations).to include(participation)
      expect(participation.target).to eq(post)
    end

    it_behaves_like "it ignores existing object received twice", Participation do
      let(:entity) { participation_entity }
    end
  end

  describe ".photo" do
    let(:photo_entity) { Fabricate(:photo_entity, author: sender.diaspora_handle) }

    it "saves the photo if it does not already exist" do
      received = Diaspora::Federation::Receive.perform(photo_entity)

      photo = Photo.find_by!(guid: photo_entity.guid)

      expect(received).to eq(photo)
      expect(photo.author).to eq(sender)
      expect(photo.remote_photo_name).to eq(photo_entity.remote_photo_name)
      expect(photo.created_at.iso8601).to eq(photo_entity.created_at.iso8601)
    end

    it "updates the photo if it is already persisted" do
      Diaspora::Federation::Receive.perform(photo_entity)

      photo = Photo.find_by!(guid: photo_entity.guid)
      photo.remote_photo_name = "foobar.jpg"
      photo.save

      received = Diaspora::Federation::Receive.perform(photo_entity)
      photo.reload

      expect(received).to eq(photo)
      expect(photo.author).to eq(sender)
      expect(photo.remote_photo_name).to eq(photo_entity.remote_photo_name)
    end

    it "does not update the photo if the author mismatches" do
      Diaspora::Federation::Receive.perform(photo_entity)

      photo = Photo.find_by!(guid: photo_entity.guid)
      photo.remote_photo_name = "foobar.jpg"
      photo.author = bob.person
      photo.save

      expect {
        Diaspora::Federation::Receive.perform(photo_entity)
      }.to raise_error Diaspora::Federation::InvalidAuthor

      photo.reload

      expect(photo.author).to eq(bob.person)
      expect(photo.remote_photo_name).to eq("foobar.jpg")
    end
  end

  describe ".poll_participation" do
    let(:post_with_poll) { FactoryGirl.create(:status_message_with_poll, author: alice.person) }
    let(:poll_participation_entity) {
      build_relayable_federation_entity(
        :poll_participation,
        {
          author:           sender.diaspora_handle,
          parent_guid:      post_with_poll.poll.guid,
          poll_answer_guid: post_with_poll.poll.poll_answers.first.guid,
          author_signature: "aa"
        },
        "new_property" => "data"
      )
    }

    it "saves the poll participation" do
      received = Diaspora::Federation::Receive.perform(poll_participation_entity)

      poll_participation = PollParticipation.find_by!(guid: poll_participation_entity.guid)

      expect(received).to eq(poll_participation)
      expect(poll_participation.author).to eq(sender)
      expect(poll_participation.poll_answer).to eq(post_with_poll.poll.poll_answers.first)
    end

    it "attaches the poll participation to the poll" do
      Diaspora::Federation::Receive.perform(poll_participation_entity)

      poll_participation = PollParticipation.find_by!(guid: poll_participation_entity.guid)

      expect(post_with_poll.poll.poll_participations).to include(poll_participation)
      expect(poll_participation.poll).to eq(post_with_poll.poll)
    end

    it "saves the signature data" do
      Diaspora::Federation::Receive.perform(poll_participation_entity)

      poll_participation = PollParticipation.find_by!(guid: poll_participation_entity.guid)

      expect(poll_participation.signature).not_to be_nil
      expect(poll_participation.signature.author_signature).to eq("aa")
      expect(poll_participation.signature.additional_data).to eq("new_property" => "data")
      expect(poll_participation.signature.order).to eq(poll_participation_entity.signature_order.map(&:to_s))
    end

    let(:entity) { poll_participation_entity }
    it_behaves_like "it ignores existing object received twice", PollParticipation
    it_behaves_like "it rejects if the root author ignores the author", PollParticipation
    it_behaves_like "it relays relayables", PollParticipation
  end

  describe ".profile" do
    let(:profile_entity) { Fabricate(:profile_entity, author: sender.diaspora_handle) }

    it "updates the profile of the person" do
      received = Diaspora::Federation::Receive.perform(profile_entity)

      profile = Profile.find(sender.profile.id)

      expect(received).to eq(profile)
      expect(profile.first_name).to eq(profile_entity.first_name)
      expect(profile.last_name).to eq(profile_entity.last_name)
      expect(profile.gender).to eq(profile_entity.gender)
      expect(profile.bio).to eq(profile_entity.bio)
      expect(profile.location).to eq(profile_entity.location)
      expect(profile.searchable).to eq(profile_entity.searchable)
      expect(profile.nsfw).to eq(profile_entity.nsfw)
      expect(profile.tag_string.split(" ")).to match_array(profile_entity.tag_string.split(" "))
      expect(profile.public_details).to eq(profile_entity.public)
    end
  end

  describe ".reshare" do
    let(:reshare_entity) { Fabricate(:reshare_entity, author: sender.diaspora_handle, root_guid: post.guid) }

    it "saves the reshare" do
      received = Diaspora::Federation::Receive.perform(reshare_entity)

      reshare = Reshare.find_by!(guid: reshare_entity.guid)

      expect(received).to eq(reshare)
      expect(reshare.author).to eq(sender)
    end

    it "attaches the reshare to the post" do
      Diaspora::Federation::Receive.perform(reshare_entity)

      reshare = Reshare.find_by!(guid: reshare_entity.guid)

      expect(post.reshares).to include(reshare)
      expect(reshare.root).to eq(post)
      expect(reshare.created_at.iso8601).to eq(reshare_entity.created_at.iso8601)
    end

    it_behaves_like "it ignores existing object received twice", Reshare do
      let(:entity) { reshare_entity }
    end
  end

  describe ".retraction" do
    it "destroys the post" do
      remote_post = FactoryGirl.create(:status_message, author: sender, public: true)

      retraction = Fabricate(
        :retraction_entity,
        author:      sender.diaspora_handle,
        target_guid: remote_post.guid,
        target_type: "Post"
      )

      expect_any_instance_of(StatusMessage).to receive(:destroy!).and_call_original

      Diaspora::Federation::Receive.retraction(retraction, nil)

      expect(StatusMessage.exists?(guid: remote_post.guid)).to be_falsey
    end

    it "raises when the post does not exist" do
      retraction = Fabricate(:retraction_entity, author: sender.diaspora_handle, target_type: "Post")

      expect {
        Diaspora::Federation::Receive.retraction(retraction, nil)
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "disconnects on Person-Retraction" do
      alice.contacts.find_or_initialize_by(person_id: sender.id, receiving: true, sharing: true).save!

      retraction = Fabricate(
        :retraction_entity,
        author:      sender.diaspora_handle,
        target_guid: sender.guid,
        target_type: "Person"
      )

      Diaspora::Federation::Receive.retraction(retraction, alice.id)

      contact = alice.contacts.find_by!(person_id: sender.id)

      expect(contact).not_to be_nil
      expect(contact.sharing).to be_falsey
    end

    context "Relayable" do
      it "relays the retraction and destroys the relayable when the parent-author is local" do
        local_post = FactoryGirl.create(:status_message, author: alice.person, public: true)
        remote_comment = FactoryGirl.create(:comment, author: sender, post: local_post)

        retraction = Fabricate(
          :retraction_entity,
          author:      sender.diaspora_handle,
          target_guid: remote_comment.guid,
          target_type: "Comment"
        )

        comment_retraction = Retraction.for(remote_comment)

        expect(Retraction).to receive(:for).with(instance_of(Comment)).and_return(comment_retraction)
        expect(comment_retraction).to receive(:defer_dispatch).with(alice, false)
        expect(comment_retraction).to receive(:perform).and_call_original
        expect_any_instance_of(Comment).to receive(:destroy!).and_call_original

        Diaspora::Federation::Receive.retraction(retraction, nil)

        expect(StatusMessage.exists?(guid: remote_comment.guid)).to be_falsey
      end

      it "destroys the relayable when the parent-author is not local" do
        remote_post = FactoryGirl.create(:status_message, author: sender, public: true)
        remote_comment = FactoryGirl.create(:comment, author: sender, post: remote_post)

        retraction = Fabricate(
          :retraction_entity,
          author:      sender.diaspora_handle,
          target_guid: remote_comment.guid,
          target_type: "Comment"
        )

        expect_any_instance_of(Comment).to receive(:destroy!).and_call_original

        Diaspora::Federation::Receive.retraction(retraction, nil)

        expect(StatusMessage.exists?(guid: remote_comment.guid)).to be_falsey
      end
    end
  end

  describe ".status_message" do
    context "basic status message" do
      let(:status_message_entity) { Fabricate(:status_message_entity, author: sender.diaspora_handle) }

      it "saves the status message" do
        received = Diaspora::Federation::Receive.perform(status_message_entity)

        status_message = StatusMessage.find_by!(guid: status_message_entity.guid)

        expect(received).to eq(status_message)
        expect(status_message.author).to eq(sender)
        expect(status_message.text).to eq(status_message_entity.text)
        expect(status_message.public).to eq(status_message_entity.public)
        expect(status_message.created_at.iso8601).to eq(status_message_entity.created_at.iso8601)
        expect(status_message.provider_display_name).to eq(status_message_entity.provider_display_name)

        expect(status_message.location).to be_nil
        expect(status_message.poll).to be_nil
        expect(status_message.photos).to be_empty
      end

      it "returns the status message if it already exists" do
        first = Diaspora::Federation::Receive.perform(status_message_entity)
        second = Diaspora::Federation::Receive.perform(status_message_entity)

        expect(second).not_to be_nil
        expect(first).to eq(second)
      end

      it "does not change anything if the status message already exists" do
        Diaspora::Federation::Receive.perform(status_message_entity)

        expect_any_instance_of(StatusMessage).not_to receive(:create_or_update)

        Diaspora::Federation::Receive.perform(status_message_entity)
      end
    end

    context "with poll" do
      let(:poll_entity) { Fabricate(:poll_entity) }
      let(:status_message_entity) {
        Fabricate(:status_message_entity, author: sender.diaspora_handle, poll: poll_entity)
      }

      it "saves the status message" do
        received = Diaspora::Federation::Receive.perform(status_message_entity)

        status_message = StatusMessage.find_by!(guid: status_message_entity.guid)

        expect(received).to eq(status_message)
        expect(status_message.author).to eq(sender)

        expect(status_message.poll.question).to eq(poll_entity.question)
        expect(status_message.poll.guid).to eq(poll_entity.guid)
        expect(status_message.poll.poll_answers.count).to eq(poll_entity.poll_answers.count)
        expect(status_message.poll.poll_answers.map(&:answer)).to eq(poll_entity.poll_answers.map(&:answer))
      end
    end

    context "with location" do
      let(:location_entity) { Fabricate(:location_entity) }
      let(:status_message_entity) {
        Fabricate(:status_message_entity, author: sender.diaspora_handle, location: location_entity)
      }

      it "saves the status message" do
        received = Diaspora::Federation::Receive.perform(status_message_entity)

        status_message = StatusMessage.find_by!(guid: status_message_entity.guid)

        expect(received).to eq(status_message)
        expect(status_message.author).to eq(sender)

        expect(status_message.location.address).to eq(location_entity.address)
        expect(status_message.location.lat).to eq(location_entity.lat)
        expect(status_message.location.lng).to eq(location_entity.lng)
      end
    end

    context "with photos" do
      let(:status_message_guid) { Fabricate.sequence(:guid) }
      let(:photo1) {
        Fabricate(:photo_entity, author: sender.diaspora_handle, status_message_guid: status_message_guid)
      }
      let(:photo2) {
        Fabricate(:photo_entity, author: sender.diaspora_handle, status_message_guid: status_message_guid)
      }
      let(:status_message_entity) {
        Fabricate(
          :status_message_entity,
          author: sender.diaspora_handle,
          guid:   status_message_guid,
          photos: [photo1, photo2]
        )
      }

      it "saves the status message and photos" do
        received = Diaspora::Federation::Receive.perform(status_message_entity)

        status_message = StatusMessage.find_by!(guid: status_message_entity.guid)

        expect(received).to eq(status_message)
        expect(status_message.author).to eq(sender)

        expect(status_message.photos.map(&:guid)).to include(photo1.guid, photo2.guid)
      end

      it "receives a status message only with photos and without text" do
        entity = DiasporaFederation::Entities::StatusMessage.new(status_message_entity.to_h.merge(text: nil))
        received = Diaspora::Federation::Receive.perform(entity)

        status_message = StatusMessage.find_by!(guid: status_message_entity.guid)

        expect(received).to eq(status_message)
        expect(status_message.author).to eq(sender)

        expect(status_message.text).to be_nil
        expect(status_message.photos.map(&:guid)).to include(photo1.guid, photo2.guid)
      end

      it "does not overwrite the photos if they already exist" do
        received_photo = Diaspora::Federation::Receive.photo(photo1)
        received_photo.text = "foobar"
        received_photo.save!

        received = Diaspora::Federation::Receive.perform(status_message_entity)

        status_message = StatusMessage.find_by!(guid: status_message_entity.guid)

        expect(received).to eq(status_message)
        expect(status_message.author).to eq(sender)

        expect(status_message.photos.map(&:guid)).to include(photo1.guid, photo2.guid)
        expect(status_message.photos.map(&:text)).to include(received_photo.text, photo2.text)
      end
    end
  end
end
