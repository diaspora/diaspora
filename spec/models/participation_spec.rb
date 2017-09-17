# frozen_string_literal: true

describe Participation, type: :model do
  let(:status) { bob.post(:status_message, text: "hello", to: bob.aspects.first.id) }

  describe "#subscribers" do
    it "returns the parent author on local parent" do
      local_parent = local_luke.post(:status_message, text: "hi", to: local_luke.aspects.first)
      participation = local_luke.participate!(local_parent)
      expect(participation.subscribers).to match_array([local_luke.person])
    end

    it "returns the parent author on remote parent" do
      remote_parent = FactoryGirl.create(:status_message, author: remote_raphael)
      participation = local_luke.participate!(remote_parent)
      expect(participation.subscribers).to match_array([remote_raphael])
    end
  end

  describe "#unparticipate" do
    before do
      @like = alice.like!(status)
    end

    it "retract participation" do
      @like.author.participations.first.unparticipate!
      participations = Participation.where(target_id: @like.target_id, author_id: @like.author_id)
      expect(participations.count).to eq(0)
    end

    it "retract one of multiple participations" do
      comment = alice.comment!(status, "bro")
      comment.author.participations.first.unparticipate!
      participations = Participation.where(target_id: @like.target_id, author_id: @like.author_id)
      expect(participations.count).to eq(1)
      expect(participations.first.count).to eq(1)
    end

    it "retract all of multiple participations" do
      alice.comment!(status, "bro")
      alice.participations.first.unparticipate!
      alice.participations.first.unparticipate!
      expect(Participation.where(target_id: @like.target_id, author_id: @like.author_id).count).to eq(0)
    end
  end
end
