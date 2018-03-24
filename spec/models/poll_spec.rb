# frozen_string_literal: true

describe Poll, type: :model do
  let(:status) { FactoryGirl.create(:status_message) }
  let(:poll) { Poll.new(question: "What do you think about apples?", status_message: status) }

  describe "validation" do
    it "should not create a poll when it has less than two answers" do
      poll.poll_answers.build(answer: "1").poll = poll
      expect(poll).not_to be_valid
    end

    it "should create a poll when it has more than two answers" do
      poll.poll_answers.build(answer: "1").poll = poll
      poll.poll_answers.build(answer: "2").poll = poll
      expect(poll).to be_valid
    end

    it "should not create a poll when question in blank" do
      poll.question = "   "
      poll.valid?
      expect(poll.errors).to have_key(:question)
    end
  end

  describe "poll_participation" do
    it "should return the answer object after a user voted in a poll" do
      answer = poll.poll_answers.build(answer: "1")
      answer.poll = poll
      poll.poll_answers.build(answer: "2").poll = poll
      poll.save
      participation = poll.poll_participations.create(poll_answer: answer, author: alice.person)
      expect(poll.participation_answer(alice)).to eql(participation)
    end

    it "should return nil if a user did not participate in a poll" do
      answer = poll.poll_answers.build(answer: "1")
      answer.poll = poll
      poll.poll_answers.build(answer: "2").poll = poll
      poll.save
      expect(poll.participation_answer(alice)).to eql(nil)
    end
  end
end
