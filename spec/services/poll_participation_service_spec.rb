# frozen_string_literal: true

describe PollParticipationService do
  let(:poll_post) { FactoryGirl.create(:status_message_with_poll, public: true) }
  let(:poll_answer) { poll_post.poll.poll_answers.first }

  describe "voting on poll" do
    it "succeeds" do
      expect(poll_service.vote(poll_post.id, poll_answer.id)).not_to be_nil
    end

    it "fails to vote twice" do
      expect(poll_service.vote(poll_post.id, poll_answer.id)).not_to be_nil
      expect { poll_service.vote(poll_post.id, poll_answer.id) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "fails with bad answer id" do
      expect { poll_service.vote(poll_post.id, -2) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "fails with bad post id" do
      expect { poll_service.vote(-1, poll_answer.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  def poll_service(user=alice)
    PollParticipationService.new(user)
  end
end
