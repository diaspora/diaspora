# frozen_string_literal: true

describe Notifications::MentionedInPostService do
  let(:sm) {
    FactoryBot.create(:status_message, author: alice.person, text: "hi @{bob; #{bob.diaspora_handle}}", public: true)
  }
  let(:mentioned_notification) { Notifications::MentionedInPost.new(recipient: bob) }

  describe ".notify" do
    it "calls create_notification with mention" do
      expect(Notifications::MentionedInPost).to receive(:create_notification).with(
        bob, sm.mentions.first, sm.author
      ).and_return(mentioned_notification)

      Notifications::MentionedInPostService.notify(sm, [])
    end

    it "sends an email to the mentioned person" do
      expect(Mail::MentionedWorker).to receive(:perform_async).with(bob.id, sm.author.id, sm.mentions.first.id)

      Notifications::MentionedInPostService.notify(sm, [])
    end

    it "does nothing if the mentioned person is not local" do
      sm = FactoryBot.create(
        :status_message,
        author: alice.person,
        text:   "hi @{raphael; #{remote_raphael.diaspora_handle}}",
        public: true
      )
      expect(Notifications::MentionedInPost).not_to receive(:create_notification)

      Notifications::MentionedInPostService.notify(sm, [])
    end

    it "does not create a notification if the author of the post is ignored" do
      bob.blocks.create(person: sm.author)

      Notifications::MentionedInPostService.notify(sm, [])

      expect(Notifications::MentionedInPost.where(target: sm.mentions.first)).not_to exist
    end

    it "does not create a notification if it already exists" do
      Notifications::MentionedInPost.create(recipient: bob, target: sm.mentions.first, actors: [sm.author])

      expect(Notifications::MentionedInPost).not_to receive(:create_notification)

      Notifications::MentionedInPostService.notify(sm, [])
    end

    context "when user disabled in app notification" do
      before do
        bob.notification_settings.create(
          type:           "mentioned",
          email_enabled:  true,
          in_app_enabled: false
        )
      end

      it "does not create a notification but still sends the email" do
        expect(Mail::MentionedWorker).to receive(:perform_async).with(bob.id, sm.author.id, sm.mentions.first.id)

        Notifications::MentionedInPostService.notify(sm, [])

        expect(Notifications::MentionedInPost.where(target: sm.mentions.first)).not_to exist
      end
    end

    context "with private post" do
      let(:private_sm) {
        FactoryBot.create(
          :status_message,
          author: remote_raphael,
          text:   "hi @{bob; #{bob.diaspora_handle}}",
          public: false
        ).tap {|private_sm|
          private_sm.receive([bob.id, alice.id])
        }
      }

      it "calls create_notification if the mentioned person is a recipient of the post" do
        expect(Notifications::MentionedInPost).to receive(:create_notification).with(
          bob, private_sm.mentions.first, private_sm.author
        ).and_return(mentioned_notification)

        Notifications::MentionedInPostService.notify(private_sm, [bob.id])
      end

      it "does not call create_notification if the mentioned person is not a recipient of the post" do
        expect(Notifications::MentionedInPost).not_to receive(:create_notification)

        Notifications::MentionedInPostService.notify(private_sm, [alice.id])
      end
    end
  end
end
