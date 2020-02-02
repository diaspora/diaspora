# frozen_string_literal: true

class PollPresenter < BasePresenter
  def initialize(poll, current_user=nil)
    super(poll, current_user)

    @participation = participation_answer(current_user) if current_user
  end

  def as_api_json
    {
      guid:                 guid,
      participation_count:  participation_count,
      question:             question,
      already_participated: @participation.present?,
      poll_answers:         answers_collection_as_api_json(poll_answers)
    }
  end

  private

  def answers_collection_as_api_json(answers_collection)
    answers_collection.map {|answer| answer_as_api_json(answer) }
  end

  def answer_as_api_json(answer)
    base = {
      id:         answer.id,
      answer:     answer.answer,
      vote_count: answer.vote_count
    }
    base[:own_answer] = @participation.try(:poll_answer_id) == answer.id if current_user
    base
  end
end
