require "spec_helper"

describe "be_new_record" do
  context "un-persisted record" do
    it "passes" do
      record = double('record', :persisted? => false)
      record.should be_new_record
    end
  end

  context "persisted record" do
    it "fails" do
      record = double('record', :persisted? => true)
      record.should_not be_new_record
    end
  end
end
