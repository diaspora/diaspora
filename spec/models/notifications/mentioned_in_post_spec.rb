# frozen_string_literal: true

describe Notifications::MentionedInPost, type: :model do
  let(:sm) {
    FactoryGirl.create(:status_message, author: alice.person, text: "hi @{bob; #{bob.diaspora_handle}}", public: true)
  }
  let(:mentioned_notification) { Notifications::MentionedInPost.new(recipient: bob) }

  describe ".notify" do
    it "calls create_notification with mention" do
      expect(Notifications::MentionedInPost).to receive(:create_notification).with(
        bob, sm.mentions.first, sm.author
      ).and_return(mentioned_notification)

      Notifications::MentionedInPost.notify(sm, [])
    end

    it "sends an email to the mentioned person" do
      allow(Notifications::MentionedInPost).to receive(:create_notification).and_return(mentioned_notification)
      expect(bob).to receive(:mail).with(Workers::Mail::Mentioned, bob.id, sm.author.id, sm.mentions.first.id)

      Notifications::MentionedInPost.notify(sm, [])
    end

    it "does nothing if the mentioned person is not local" do
      sm = FactoryGirl.create(
        :status_message,
        author: alice.person,
        text:   "hi @{raphael; #{remote_raphael.diaspora_handle}}",
        public: true
      )
      expect(Notifications::MentionedInPost).not_to receive(:create_notification)

      Notifications::MentionedInPost.notify(sm, [])
    end

    it "does not notify if the author of the post is ignored" do
      bob.blocks.create(person: sm.author)

      expect_any_instance_of(Notifications::MentionedInPost).not_to receive(:email_the_user)

      Notifications::MentionedInPost.notify(sm, [])

      expect(Notifications::MentionedInPost.where(target: sm.mentions.first)).not_to exist
    end

    context "with private post" do
      let(:private_sm) {
        FactoryGirl.create(
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

        Notifications::MentionedInPost.notify(private_sm, [bob.id])
      end

      it "does not call create_notification if the mentioned person is not a recipient of the post" do
        expect(Notifications::MentionedInPost).not_to receive(:create_notification)

        Notifications::MentionedInPost.notify(private_sm, [alice.id])
      end
    end
  end
end
