# frozen_string_literal: true

RSpec::Matchers.define :have_subscribers do
  match do |posts|
    posts.map(&:subscribers).delete_if(&:empty?).any?
  end
end

# verifications of data generation (protect us from possible false positives in case of poor data preset)
describe DataGenerator do
  let(:user) { FactoryGirl.create(:user) }
  let(:generator) { DataGenerator.new(user) }

  describe "#generic_user_data" do
    it "creates different data for user" do
      generator.generic_user_data
      expect(user.aspects).not_to be_empty
      expect(Post.subscribed_by(user)).not_to be_empty
      expect(Contact.where(user: user).mutual).not_to be_empty
    end
  end

  describe "#status_messages_flavours" do
    let(:user) { FactoryGirl.create(:user_with_aspect) }

    it "creates posts of different types" do
      expect(generator).to receive(:status_message_with_activity).and_call_original
      generator.status_messages_flavours
      expect(user.posts).not_to be_empty
      expect(user.posts.where(public: true)).to have_subscribers
      expect(user.posts.where(public: false)).to have_subscribers
    end
  end

  describe "#status_message_with_activity" do
    it "creates a status message where presented all possible types of activity" do
      status_message = generator.status_message_with_activity
      expect(status_message.likes).not_to be_empty
      expect(status_message.comments).not_to be_empty
      expect(status_message.poll_participations).not_to be_empty
    end
  end

  describe "#activity" do
    it "creates activity of different kinds" do
      generator.activity
      expect(user.posts.reshares).not_to be_empty
      expect(user.person.likes).not_to be_empty
      expect(user.person.comments).not_to be_empty
      expect(user.person.poll_participations).not_to be_empty
    end
  end

  describe "#status_message_with_subscriber" do
    it "creates a status message with a subscriber" do
      subscriber, status_message = DataGenerator.create(user, :status_message_with_subscriber)
      expect(status_message.subscribers).to eq([subscriber.person])
    end
  end
end
