# frozen_string_literal: true

describe Diaspora::Exporter::OthersRelayables do
  let(:status_message) { FactoryGirl.create(:status_message) }
  let(:person) { status_message.author }
  let(:instance) { Diaspora::Exporter::OthersRelayables.new(person.id) }

  describe "#comments" do
    let(:comment) { FactoryGirl.create(:comment, post: status_message) }

    it "has a comment in the data set" do
      expect(instance.comments).to eq([comment])
    end
  end

  describe "#likes" do
    let(:like) { FactoryGirl.create(:like, target: status_message) }

    it "has a like in the data set" do
      expect(instance.likes).to eq([like])
    end
  end

  describe "#poll_participations" do
    let(:status_message) { FactoryGirl.create(:status_message_with_poll) }
    let(:poll_participation) {
      FactoryGirl.create(
        :poll_participation,
        poll_answer: status_message.poll.poll_answers.first
      )
    }

    it "has a poll participation in the data set" do
      expect(instance.poll_participations).to eq([poll_participation])
    end
  end
end
