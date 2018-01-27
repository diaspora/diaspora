# frozen_string_literal: true

describe Block, type: :model do
  describe "validations" do
    it "doesnt allow you to block yourself" do
      block = alice.blocks.create(person: alice.person)
      expect(block.errors[:person_id].size).to eq(1)
    end
  end

  describe "#subscribers" do
    it "returns an array with recipient of the block" do
      block = alice.blocks.create(person: eve.person)
      expect(block.subscribers).to match_array([eve.person])
    end
  end
end
