# frozen_string_literal: true

describe PollParticipation, type: :model do
  let(:status) { bob.post(:status_message, text: "hello", to: bob.aspects.first.id) }
  let(:poll) { Poll.new(question: "Who is in charge?") }

  before do
    poll.poll_answers.build(answer: "a").poll = poll
    poll.poll_answers.build(answer: "b").poll = poll
    status.poll = poll
  end

  describe 'validation' do
    it 'forbids multiple participations in the same poll' do
      expect {
        2.times do |run|
          bob.participate_in_poll!(status, poll.poll_answers.first)
        end
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'allows a one time participation in a poll' do
      expect {
        bob.participate_in_poll!(status, poll.poll_answers.first)
      }.to_not raise_error
    end
  end

  it_behaves_like "it is relayable" do
    let(:remote_parent) { FactoryGirl.create(:status_message_with_poll, author: remote_raphael) }
    let(:local_parent) {
      FactoryGirl.create(:status_message_with_poll, author: local_luke.person).tap do |status_message|
        local_luke.add_to_streams(status_message, [local_luke.aspects.first])
      end
    }
    let(:object_on_local_parent) { local_luke.participate_in_poll!(local_parent, local_parent.poll.poll_answers.first) }
    let(:object_on_remote_parent) {
      local_luke.participate_in_poll!(remote_parent, remote_parent.poll.poll_answers.first)
    }
    let(:remote_object_on_local_parent) {
      FactoryGirl.create(:poll_participation, poll_answer: local_parent.poll.poll_answers.first, author: remote_raphael)
    }
    let(:relayable) { PollParticipation::Generator.new(alice, status, poll.poll_answers.first).build }
  end
end
