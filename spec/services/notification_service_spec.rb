# frozen_string_literal: true

describe NotificationService do
  describe "notification interrelation" do
    context "with mention in comment" do
      let(:status_message) {
        FactoryGirl.create(:status_message, public: true, author: alice.person).tap {|status_message|
          eve.comment!(status_message, "whatever")
        }
      }

      let(:comment) {
        FactoryGirl.create(
          :comment,
          author: bob.person,
          text:   text_mentioning(alice, eve),
          post:   status_message
        )
      }

      it "sends only mention notification" do
        [alice, eve].each do |user|
          expect(Workers::Mail::MentionedInComment).to receive(:perform_async).with(
            user.id,
            bob.person.id,
            *comment.mentions.where(person: user.person).ids
          )
        end

        expect {
          NotificationService.new.notify(comment, [])
        }.to change { Notification.where(recipient_id: alice).count }.by(1)
          .and change { Notification.where(recipient_id: eve).count }.by(1)

        [alice, eve].each do |user|
          expect(
            Notifications::MentionedInComment.where(target: comment.mentions, recipient_id: user.id)
          ).to exist

          expect(
            Notifications::CommentOnPost.where(target: comment.parent, recipient_id: user.id)
          ).not_to exist

          expect(
            Notifications::AlsoCommented.where(target: comment.parent, recipient_id: user.id)
          ).not_to exist
        end
      end

      context "with \"mentioned in comment\" email turned off" do
        before do
          alice.user_preferences.create(email_type: "mentioned_in_comment")
          eve.user_preferences.create(email_type: "mentioned_in_comment")
        end

        it "calls appropriate mail worker instead" do
          expect(Workers::Mail::MentionedInComment).not_to receive(:perform_async)

          expect(Workers::Mail::CommentOnPost).to receive(:perform_async).with(
            alice.id,
            bob.person.id,
            *comment.mentions.where(person: alice.person).ids
          )

          expect(Workers::Mail::AlsoCommented).to receive(:perform_async).with(
            eve.id,
            bob.person.id,
            *comment.mentions.where(person: eve.person).ids
          )

          NotificationService.new.notify(comment, [])
        end
      end
    end
  end
end
