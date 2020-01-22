# frozen_string_literal: true

describe PollPresenter do
  let(:poll) { FactoryGirl.create(:status_message_with_poll, public: true).poll }
  let(:poll_answer) { poll.poll_answers.first }

  describe "#poll" do
    it "works without a user" do
      presenter = PollPresenter.new(poll)
      confirm_poll_api_json_format(presenter.as_api_json, 0, false)
    end

    it "works with user" do
      presenter = PollPresenter.new(poll, alice)
      confirm_poll_api_json_format(presenter.as_api_json, 0, false)
      poll.poll_participations.create(poll_answer: poll_answer, author: alice.person)
      confirm_poll_api_json_format(presenter.as_api_json, 1, true)
      presenter = PollPresenter.new(poll, eve)
      confirm_poll_api_json_format(presenter.as_api_json, 1, false)
      presenter = PollPresenter.new(poll)
      confirm_poll_api_json_format(presenter.as_api_json, 1, false)
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def confirm_poll_api_json_format(response, expected_count, expected_participation)
    expect(response).to include(guid: poll.guid)
    expect(response).to include(participation_count: expected_count)
    expect(response).to include(already_participated: expected_participation)
    expect(response).to include(question: poll.question)
    expect(response.has_key?(:poll_answers)).to be_truthy

    answer = response[:poll_answers].find {|a| a[:id] == poll_answer.id }
    expect(answer[:answer]).to eq(poll_answer.answer)
    expect(answer[:vote_count]).to eq(poll_answer.vote_count)
  end
  # rubocop:enable Metrics/AbcSize
end
