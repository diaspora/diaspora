# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Notifications::AlsoCommented, type: :model do
  let(:sm) { FactoryBot.build(:status_message, author: alice.person, public: true) }
  let(:comment) { FactoryBot.create(:comment, commentable: sm) }
  let(:notification) { Notifications::AlsoCommented.new(recipient: bob) }

  describe ".notify" do
    it "does not notify the commentable author" do
      expect(Notifications::AlsoCommented).not_to receive(:concatenate_or_create)

      Notifications::AlsoCommented.notify(comment, [])
    end

    it "notifies a local participant" do
      bob.participate!(sm)

      expect(Notifications::AlsoCommented).to receive(:concatenate_or_create).with(
        bob, sm, comment.author
      ).and_return(notification)
      expect(bob).to receive(:mail).with(Workers::Mail::AlsoCommented, bob.id, comment.author.id, comment.id)

      Notifications::AlsoCommented.notify(comment, [])
    end

    it "does not notify the a remote participant" do
      FactoryBot.create(:participation, target: sm)

      expect(Notifications::AlsoCommented).not_to receive(:concatenate_or_create)

      Notifications::AlsoCommented.notify(comment, [])
    end

    it "does not notify the author of the comment" do
      bob.participate!(sm)
      comment = FactoryBot.create(:comment, commentable: sm, author: bob.person)

      expect(Notifications::AlsoCommented).not_to receive(:concatenate_or_create)

      Notifications::AlsoCommented.notify(comment, [])
    end

    it "does not notify if the commentable is hidden" do
      bob.participate!(sm)
      bob.add_hidden_shareable(sm.class.base_class.to_s, sm.id.to_s)

      expect(Notifications::AlsoCommented).not_to receive(:concatenate_or_create)

      Notifications::AlsoCommented.notify(comment, [])
    end

    it "does not notify if the author of the comment is ignored" do
      bob.participate!(sm)
      bob.blocks.create(person: comment.author)

      expect_any_instance_of(Notifications::AlsoCommented).not_to receive(:email_the_user)

      Notifications::AlsoCommented.notify(comment, [])

      expect(Notifications::AlsoCommented.where(target: sm)).not_to exist
    end

    context "when user disabled in app notification" do
      before do
        bob.user_preferences.create(
          email_type:     "also_commented",
          in_app_enabled: false
        )
      end

      it "does not notify" do
        bob.participate!(sm)

        expect_any_instance_of(Notifications::AlsoCommented).not_to receive(:email_the_user)

        Notifications::AlsoCommented.notify(comment, [])

        expect(Notifications::AlsoCommented.where(target: sm)).not_to exist
      end
    end
  end
end
