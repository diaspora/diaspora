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
      }.to raise_error
    end

    it 'allows a one time participation in a poll' do
      expect {
        bob.participate_in_poll!(@status, @poll.poll_answers.first)
      }.to_not raise_error
    end

  end

  describe 'xml' do
    before do
      @poll_participant = FactoryGirl.create(:user)
      @poll_participant_aspect = @poll_participant.aspects.create(:name => "bruisers")
      connect_users(alice, @alices_aspect, @poll_participant, @poll_participant_aspect)
      @poll = Poll.new(:question => "hi")
      @poll.poll_answers.build(:answer => "a")
      @poll.poll_answers.build(:answer => "b")
      @post = alice.post :status_message, :text => "hello", :to => @alices_aspect.id
      @post.poll = @poll
      @poll_participation = @poll_participant.participate_in_poll!(@post, @poll.poll_answers.first)
      @xml = @poll_participation.to_xml.to_s
    end

    it 'serializes the class name' do
      expect(@xml.include?(PollParticipation.name.underscore.to_s)).to be true
    end

    it 'serializes the sender handle' do
      expect(@xml.include?(@poll_participation.diaspora_handle)).to be true
    end

    it 'serializes the poll_guid' do
      expect(@xml).to include(@poll.guid)
    end

    it 'serializes the poll_answer_guid' do
      expect(@xml).to include(@poll_participation.poll_answer.guid)
    end

    describe 'marshalling' do
      before do
        @marshalled_poll_participation = PollParticipation.from_xml(@xml)
      end

      it 'marshals the author' do
        expect(@marshalled_poll_participation.author).to eq(@poll_participant.person)
      end

      it 'marshals the answer' do
        expect(@marshalled_poll_participation.poll_answer).to eq(@poll_participation.poll_answer)
      end

      it 'marshals the poll' do
        expect(@marshalled_poll_participation.poll).to eq(@poll)
      end
    end
  end

  describe 'federation' do
    before do
      #Alice is on pod A and another person is on pod B. Alice posts a poll and participates in the poll.
      @poll_participant = FactoryGirl.create(:user)
      @poll_participant_aspect = @poll_participant.aspects.create(:name => "bruisers")
      connect_users(alice, @alices_aspect, @poll_participant, @poll_participant_aspect)
      @poll = Poll.new(:question => "hi")
      @poll.poll_answers.build(:answer => "a")
      @poll.poll_answers.build(:answer => "b")
      @post = alice.post :status_message, :text => "hello", :to => @alices_aspect.id
      @post.poll = @poll
      @poll_participation_alice = alice.participate_in_poll!(@post, @poll.poll_answers.first)
    end

    it 'is saved without errors in a simulated A-B node environment' do
      #stubs needed because the poll participation is already saved in the test db. This is just a simulated federation!
      allow_any_instance_of(PollParticipation).to receive(:save!).and_return(true)
      allow_any_instance_of(Person).to receive(:local?).and_return(false)
      expect{
        salmon = Salmon::Slap.create_by_user_and_activity(alice, @poll_participation_alice.to_diaspora_xml).xml_for(@poll_participant)
        Postzord::Receiver::Public.new(salmon).save_object
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
