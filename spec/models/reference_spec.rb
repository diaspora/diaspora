# frozen_string_literal: true

describe Reference, type: :model do
  context "validation" do
    it "validates a valid reference" do
      expect(FactoryGirl.build(:reference)).to be_valid
    end

    it "requires a source" do
      expect(FactoryGirl.build(:reference, source: nil)).not_to be_valid
    end

    it "requires a target" do
      expect(FactoryGirl.build(:reference, target: nil)).not_to be_valid
    end

    it "disallows to link the same target twice from one source" do
      reference = FactoryGirl.create(:reference)
      expect(FactoryGirl.build(:reference, source: reference.source, target: reference.target)).not_to be_valid
    end
  end
end
