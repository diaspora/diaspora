# frozen_string_literal: true

describe ArchiveValidator do
  let(:json_string) { "{}" }
  let(:json_file) { StringIO.new(json_string) }
  let(:archive_validator) { ArchiveValidator.new(json_file) }

  describe "#validate" do
    context "when bad json passed" do
      let(:json_string) { "#@)g?$0" }

      it "contains critical error" do
        archive_validator.validate
        expect(archive_validator.errors.first).to include("Bad JSON provided")
      end
    end
  end
end
