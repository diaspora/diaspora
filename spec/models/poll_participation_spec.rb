require 'spec_helper'
require Rails.root.join("spec", "shared_behaviors", "relayable")

describe PollParticipation, :type => :model do
  before do
    @alices_aspect = alice.aspects.first
    @status = bob.post(:status_message, :text => "hello", :to => bob.aspects.first.id)
    @poll = Poll.new(:question => 'Who is in charge?')
    @poll.poll_answers.build(:answer => "a")
    @poll.poll_answers.build(:answer => "b")
    @status.poll = @poll
  end

  describe 'validation' do
    it 'forbids multiple participations in the same poll' do
      expect {
        2.times do |run|
          bob.participate_in_poll!(@status, @poll.poll_answers.first)
        end
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'allows a one time participation in a poll' do
      expect {
        bob.participate_in_poll!(@status, @poll.poll_answers.first)
      }.to_not raise_error
    end
  end

  describe 'it is relayable' do
    before do
      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @remote_parent = FactoryGirl.build(:status_message_with_poll, :author => @remote_raphael)

      @local_parent = @local_luke.post :status_message, :text => "hi", :to => @local_luke.aspects.first
      @poll2 = Poll.new(:question => 'Who is now in charge?')
      @poll2.poll_answers.build(:answer => "a")
      @poll2.poll_answers.build(:answer => "b")
      @local_parent.poll = @poll2

      @object_by_parent_author = @local_luke.participate_in_poll!(@local_parent, @poll2.poll_answers.first)
      @object_by_recipient = @local_leia.participate_in_poll!(@local_parent, @poll2.poll_answers.first)
      @dup_object_by_parent_author = @object_by_parent_author.dup

      @object_on_remote_parent = @local_luke.participate_in_poll!(@remote_parent, @remote_parent.poll.poll_answers.first)
    end

  let(:build_object) { PollParticipation::Generator.new(alice, @status, @poll.poll_answers.first).build }
  it_should_behave_like 'it is relayable'
  end
end
