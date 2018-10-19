# frozen_string_literal: true

class PollPresenter < BasePresenter
  def initialize(poll, participant_user=nil)
    @poll = poll
    @user = participant_user
  end

  def as_api_json
    {
      guid:                 @poll.guid,
      participation_count:  @poll.participation_count,
      question:             @poll.question,
      already_participated: @user && @poll.participation_answer(@user) ? true : false,
      poll_answers:         answers_collection_as_api_json(@poll.poll_answers)
    }
  end

  private

  def answers_collection_as_api_json(answers_collection)
    answers_collection.map {|answer| answer_as_api_json(answer) }
  end

  def answer_as_api_json(answer)
    {
      id:         answer.id,
      answer:     answer.answer,
      vote_count: answer.vote_count
    }
  end
end
