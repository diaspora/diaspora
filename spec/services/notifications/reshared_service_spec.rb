# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Notifications::ResharedService do
  let(:sm) { FactoryBot.build(:status_message, author: alice.person, public: true) }
  let(:reshare) { FactoryBot.build(:reshare, root: sm) }
  let(:reshared_notification) { Notifications::Reshared.new(recipient: alice) }

  describe ".notify" do
    it "calls concatenate_or_create with root post" do
      expect(Notifications::Reshared).to receive(:concatenate_or_create).with(
        alice, reshare.root, reshare.author
      ).and_return(reshared_notification)

      Notifications::ResharedService.notify(reshare, [])
    end

    it "sends an email to the root author" do
      allow(Notifications::Reshared).to receive(:concatenate_or_create).and_return(reshared_notification)
      expect(Mail::ResharedWorker).to receive(:perform_async).with(alice.id, reshare.author.id, reshare.id)

      Notifications::ResharedService.notify(reshare, [])
    end

    it "does nothing if the root was deleted" do
      reshare.root = nil
      expect(Notifications::Reshared).not_to receive(:concatenate_or_create)

      Notifications::ResharedService.notify(reshare, [])
    end

    it "does nothing if the root author is not local" do
      sm.author = remote_raphael
      expect(Notifications::Reshared).not_to receive(:concatenate_or_create)

      Notifications::ResharedService.notify(reshare, [])
    end

    it "does not create a notification if the author of the reshare is ignored" do
      alice.blocks.create(person: reshare.author)

      Notifications::ResharedService.notify(reshare, [])

      expect(Notifications::Reshared.where(target: sm)).not_to exist
    end

    context "when user disabled in app notification" do
      before do
        alice.notification_settings.create(
          type:           "reshared",
          email_enabled:  true,
          in_app_enabled: false
        )
      end

      it "does not create a notification but still sends the email" do
        expect(Mail::ResharedWorker).to receive(:perform_async).with(alice.id, reshare.author.id, reshare.id)

        Notifications::ResharedService.notify(reshare, [])

        expect(Notifications::Reshared.where(target: sm)).not_to exist
      end
    end
  end
end
