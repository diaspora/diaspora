# frozen_string_literal: true

describe Workers::Mail::Liked do
  describe "#perform" do
    it "should call .deliver_now on the notifier object" do
      sm = FactoryGirl.build(:status_message, author: bob.person, public: true)
      like = FactoryGirl.build(:like, author: alice.person, target: sm)

      mail_double = double
      expect(mail_double).to receive(:deliver_now)
      expect(Notifier).to receive(:send_notification)
        .with("liked", bob.id, like.author.id, like.id).and_return(mail_double)

      Workers::Mail::Liked.new.perform(bob.id, like.author.id, like.id)
    end

    it "should not fail if the like is not found" do
      sm = FactoryGirl.build(:status_message, author: bob.person, public: true)
      like = FactoryGirl.build(:like, author: alice.person, target: sm)

      expect(Notifier).to receive(:send_notification).with("liked", bob.id, like.author.id, like.id)
        .and_raise(ActiveRecord::RecordNotFound.new("Couldn't find Like with 'id'=42"))

      Workers::Mail::Liked.new.perform(bob.id, like.author.id, like.id)
    end

    it "should fail if the sender is not found" do
      sm = FactoryGirl.build(:status_message, author: bob.person, public: true)
      like = FactoryGirl.build(:like, author: alice.person, target: sm)

      expect(Notifier).to receive(:send_notification).with("liked", bob.id, like.author.id, like.id)
        .and_raise(ActiveRecord::RecordNotFound.new("Couldn't find Person with 'id'=42"))

      expect {
        Workers::Mail::Liked.new.perform(bob.id, like.author.id, like.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
