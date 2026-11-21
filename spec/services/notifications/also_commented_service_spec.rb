# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Notifications::AlsoCommentedService do
  let(:sm) { FactoryBot.build(:status_message, author: alice.person, public: true) }
  let(:comment) { FactoryBot.create(:comment, commentable: sm) }
  let(:notification) { Notifications::AlsoCommented.new(recipient: bob) }

  describe ".notify" do
    it "does not notify the commentable author" do
      expect(Notifications::AlsoCommented).not_to receive(:concatenate_or_create)

      Notifications::AlsoCommentedService.notify(comment, [])
    end

    it "notifies a local participant" do
      bob.participate!(sm)

      expect(Notifications::AlsoCommented).to receive(:concatenate_or_create).with(
        bob, sm, comment.author
      ).and_return(notification)
      expect(Mail::AlsoCommentedWorker).to receive(:perform_async).with(bob.id, comment.author.id, comment.id)

      Notifications::AlsoCommentedService.notify(comment, [])
    end

    it "does not notify the a remote participant" do
      FactoryBot.create(:participation, target: sm)

      expect(Notifications::AlsoCommented).not_to receive(:concatenate_or_create)

      Notifications::AlsoCommentedService.notify(comment, [])
    end

    it "does not notify the author of the comment" do
      bob.participate!(sm)
      comment = FactoryBot.create(:comment, commentable: sm, author: bob.person)

      expect(Notifications::AlsoCommented).not_to receive(:concatenate_or_create)

      Notifications::AlsoCommentedService.notify(comment, [])
    end

    it "does not notify if the commentable is hidden" do
      bob.participate!(sm)
      bob.add_hidden_shareable(sm.class.base_class.to_s, sm.id.to_s)

      expect(Notifications::AlsoCommented).not_to receive(:concatenate_or_create)

      Notifications::AlsoCommentedService.notify(comment, [])
    end

    it "does not create a notification if the author of the comment is ignored" do
      bob.participate!(sm)
      bob.blocks.create(person: comment.author)

      Notifications::AlsoCommentedService.notify(comment, [])

      expect(Notifications::AlsoCommented.where(target: sm)).not_to exist
    end

    context "when user disabled in app notification" do
      before do
        bob.notification_settings.create(
          type:           "also_commented",
          email_enabled:  true,
          in_app_enabled: false
        )
      end

      it "does not create a notification but still sends the email" do
        bob.participate!(sm)

        expect(Mail::AlsoCommentedWorker).to receive(:perform_async).with(bob.id, comment.author.id, comment.id)

        Notifications::AlsoCommentedService.notify(comment, [])

        expect(Notifications::AlsoCommented.where(target: sm)).not_to exist
      end
    end
  end
end
