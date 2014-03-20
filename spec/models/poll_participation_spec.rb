require 'spec_helper'
require Rails.root.join("spec", "shared_behaviors", "relayable")

describe PollParticipation do
  
  before do
    @alices_aspect = alice.aspects.first
    @status = bob.post(:status_message, :text => "hello", :to => bob.aspects.first.id)
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

    it 'serializes the sender handle' do
      @xml.include?(@poll_participation.diaspora_handle).should be_true
    end

    it 'serializes the poll_guid' do
      @xml.should include(@poll.guid)
    end

    it 'serializes the poll_answer_guid' do
      @xml.should include(@poll_participation.poll_answer.guid)
    end

    describe 'marshalling' do
      before do
        @marshalled_poll_participation = PollParticipation.from_xml(@xml)
      end

      it 'marshals the author' do
        @marshalled_poll_participation.author.should == @poll_participant.person
      end

      it 'marshals the answer' do
        @marshalled_poll_participation.poll_answer.should == @poll_participation.poll_answer
      end

      it 'marshals the poll' do
        @marshalled_poll_participation.poll.should == @poll
      end
    end
  end

  # describe 'it is relayable' do
	 #  before do
  #     @poll = Poll.new
  #     @poll_answer = PollAnswer.new(:answer => '1')
  #     @poll_answer2 = PollAnswer.new(:answer => '1')
  #     @poll.answers << [poll_answer, poll_answer2]
  #     @status.poll = @poll

	 #    @local_luke, @local_leia, @remote_raphael = set_up_friends
	 #    @remote_parent = FactoryGirl.build(:status_message, :author => @remote_raphael)
	 #    @local_parent = @local_luke.post :status_message, :text => "hi", :to => @local_luke.aspects.first

	 #    @object_by_parent_author = @local_luke.vote!(@local_parent, @poll_answer)
	 #    @object_by_recipient = @local_leia.vote!(@local_parent, @poll_answer)
	 #    @dup_object_by_parent_author = @object_by_parent_author.dup

	 #    @object_on_remote_parent = @local_luke.comment!(@remote_parent, "Yeah, it was great")
	 #  end

  # let(:build_object) { alice.build_poll_participation(:poll => @poll, :poll_answer => @poll_answer) }
  # it_should_behave_like 'it is relayable'
  # end
end
