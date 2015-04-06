require "spec_helper"

describe Participation, :type => :model do
  describe 'it is relayable' do
    before do
      @status = bob.post(:status_message, :text => "hello", :to => bob.aspects.first.id)

      @local_luke, @local_leia, @remote_raphael = set_up_friends
      @remote_parent = FactoryGirl.create(:status_message, :author => @remote_raphael)
      @local_parent = @local_luke.post :status_message, :text => "foobar", :to => @local_luke.aspects.first

      @object_by_parent_author = @local_luke.participate!(@local_parent)
      @object_by_recipient = @local_leia.participate!(@local_parent)
      @dup_object_by_parent_author = @object_by_parent_author.dup

      @object_on_remote_parent = @local_luke.participate!(@remote_parent)
    end

    let(:build_object) { Participation::Generator.new(alice, @status).build }

    it_should_behave_like 'it is relayable'
  end

  describe "#unparticipate" do
    before do
      @status = bob.post(:status_message, text: "hello", to: bob.aspects.first.id)
      @like = alice.like!(@status)
    end

    it "retract participation" do
      @like.author.participations.first.unparticipate!
      participations = Participation.where(target_id: @like.target_id, author_id: @like.author_id)
      expect(participations.count).to eq(0)
    end

    it "retract one of multiple participations" do
      comment = alice.comment!(@status, "bro")
      comment.author.participations.first.unparticipate!
      participations = Participation.where(target_id: @like.target_id, author_id: @like.author_id)
      expect(participations.count).to eq(1)
      expect(participations.first.count).to eq(1)
    end

    it "retract all of multiple participations" do
      alice.comment!(@status, "bro")
      alice.participations.first.unparticipate!
      alice.participations.first.unparticipate!
      expect(Participation.where(target_id: @like.target_id, author_id: @like.author_id).count).to eq(0)
    end
  end
end
