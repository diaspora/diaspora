# frozen_string_literal: true

describe Block, :type => :model do
  describe "validations" do
    it "doesnt allow you to block yourself" do
      block = alice.blocks.create(person: alice.person)
      expect(block.errors[:person_id].size).to eq(1)
    end
  end
end
