require 'spec_helper'

describe PollAnswer do
  before do
    @status = FactoryGirl.create(:status_message_with_poll)
    @user = alice
    @answer = @status.poll.poll_answers.first
  end

  describe 'counter cache' do
    it 'increments the counter cache on the answer' do
      lambda {
        alice.participate_in_poll!(@status, @answer)
      }.should change{
        @answer.reload.vote_count
      }.by(1)
    end

  end

  describe 'validation' do
    it 'should validate pressence of answer' do
      answer = PollAnswer.new
      answer.valid?
      answer.errors.should have_key(:answer)
    end
    it 'answer should not empty' do
      answer = PollAnswer.new answer: '  '
      answer.valid?
      answer.errors.should have_key(:answer)
    end
  end

end
