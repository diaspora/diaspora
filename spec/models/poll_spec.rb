require 'spec_helper'

describe Poll do
  before do
    @poll = Poll.new(:question => "What do you think about apples?")
  end

  describe 'validation' do
    it 'should not create a poll when it has less than two answers' do
    	@poll.poll_answers.build(:answer => '1')
    	@poll.should_not be_valid
    end

    it 'should create a poll when it has more than two answers' do
    	@poll.poll_answers.build(:answer => '1')
    	@poll.poll_answers.build(:answer => '2')
    	@poll.should be_valid
    end

    it 'should not create a poll when question in blank' do
      @poll.question = '   '
      @poll.valid?
      @poll.errors.should have_key(:question)
    end
  end
end
