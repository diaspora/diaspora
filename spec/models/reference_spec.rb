# frozen_string_literal: true

describe Reference, type: :model do
  context "validation" do
    it "validates a valid reference" do
      expect(FactoryBot.build(:reference)).to be_valid
    end

    it "requires a source" do
      expect(FactoryBot.build(:reference, source: nil)).not_to be_valid
    end

    it "requires a target" do
      expect(FactoryBot.build(:reference, target: nil)).not_to be_valid
    end

    it "disallows to link the same target twice from one source" do
      reference = FactoryBot.create(:reference)
      expect(FactoryBot.build(:reference, source: reference.source, target: reference.target)).not_to be_valid
    end
  end
end
