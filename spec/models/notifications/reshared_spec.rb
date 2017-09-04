# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Notifications::Reshared, type: :model do
  let(:sm) { FactoryGirl.build(:status_message, author: alice.person, public: true) }
  let(:reshare) { FactoryGirl.build(:reshare, root: sm) }
  let(:reshared_notification) { Notifications::Reshared.new(recipient: alice) }

  describe ".notify" do
    it "calls concatenate_or_create with root post" do
      expect(Notifications::Reshared).to receive(:concatenate_or_create).with(
        alice, reshare.root, reshare.author
      ).and_return(reshared_notification)

      Notifications::Reshared.notify(reshare, [])
    end

    it "sends an email to the root author" do
      allow(Notifications::Reshared).to receive(:concatenate_or_create).and_return(reshared_notification)
      expect(alice).to receive(:mail).with(Workers::Mail::Reshared, alice.id, reshare.author.id, reshare.id)

      Notifications::Reshared.notify(reshare, [])
    end

    it "does nothing if the root was deleted" do
      reshare.root = nil
      expect(Notifications::Reshared).not_to receive(:concatenate_or_create)

      Notifications::Reshared.notify(reshare, [])
    end

    it "does nothing if the root author is not local" do
      sm.author = remote_raphael
      expect(Notifications::Reshared).not_to receive(:concatenate_or_create)

      Notifications::Reshared.notify(reshare, [])
    end

    it "does not notify if the author of the reshare is ignored" do
      alice.blocks.create(person: reshare.author)

      expect_any_instance_of(Notifications::Reshared).not_to receive(:email_the_user)

      Notifications::Reshared.notify(reshare, [])

      expect(Notifications::Reshared.where(target: sm)).not_to exist
    end
  end
end
