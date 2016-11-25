describe Notifications::Mentioned, type: :model do
  let(:sm) {
    FactoryGirl.create(:status_message, author: alice.person, text: "hi @{bob; #{bob.diaspora_handle}}", public: true)
  }
  let(:mentioned_notification) { Notifications::Mentioned.new(recipient: bob) }

  describe ".notify" do
    it "calls create_notification with mention" do
      expect(Notifications::Mentioned).to receive(:create_notification).with(
        bob, sm.mentions.first, sm.author
      ).and_return(mentioned_notification)

      Notifications::Mentioned.notify(sm, [])
    end

    it "sends an email to the mentioned person" do
      allow(Notifications::Mentioned).to receive(:create_notification).and_return(mentioned_notification)
      expect(bob).to receive(:mail).with(Workers::Mail::Mentioned, bob.id, sm.author.id, sm.mentions.first.id)

      Notifications::Mentioned.notify(sm, [])
    end

    it "does nothing if the mentioned person is not local" do
      sm = FactoryGirl.create(
        :status_message,
        author: alice.person,
        text:   "hi @{raphael; #{remote_raphael.diaspora_handle}}",
        public: true
      )
      expect(Notifications::Mentioned).not_to receive(:create_notification)

      Notifications::Mentioned.notify(sm, [])
    end

    it "does not notify if the author of the post is ignored" do
      bob.blocks.create(person: sm.author)

      expect_any_instance_of(Notifications::Mentioned).not_to receive(:email_the_user)

      Notifications::Mentioned.notify(sm, [])

      expect(Notifications::Mentioned.where(target: sm.mentions.first)).not_to exist
    end

    context "with private post" do
      let(:private_sm) {
        FactoryGirl.create(
          :status_message,
          author: remote_raphael,
          text:   "hi @{bob; #{bob.diaspora_handle}}",
          public: false
        )
      }

      it "calls create_notification if the mentioned person is a recipient of the post" do
        expect(Notifications::Mentioned).to receive(:create_notification).with(
          bob, private_sm.mentions.first, private_sm.author
        ).and_return(mentioned_notification)

        Notifications::Mentioned.notify(private_sm, [bob.id])
      end

      it "does not call create_notification if the mentioned person is not a recipient of the post" do
        expect(Notifications::Mentioned).not_to receive(:create_notification)

        Notifications::Mentioned.notify(private_sm, [alice.id])
      end
    end
  end
end
