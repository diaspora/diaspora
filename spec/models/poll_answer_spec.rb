# frozen_string_literal: true

describe PollAnswer, :type => :model do
  before do
    @status = FactoryGirl.create(:status_message_with_poll)
    @user = alice
    @answer = @status.poll.poll_answers.first
  end

  describe 'counter cache' do
    it 'increments the counter cache on the answer' do
      expect {
        alice.participate_in_poll!(@status, @answer)
      }.to change{
        @answer.reload.vote_count
      }.by(1)
    end

  end

  describe 'validation' do
    it 'should validate pressence of answer' do
      answer = PollAnswer.new
      answer.valid?
      expect(answer.errors).to have_key(:answer)
    end
    it 'answer should not empty' do
      answer = PollAnswer.new answer: '  '
      answer.valid?
      expect(answer.errors).to have_key(:answer)
    end
  end

end
