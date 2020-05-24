# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::PostValidator do
  include_context "validators shared context"
  include_context "with known author"

  let(:guid) { UUID.generate(:compact) }
  let(:validator) { described_class.new(input_hash, reshare) }

  context "with a reshare with no root" do
    let(:reshare) {
      {
        "entity_data" => {
          "guid"       => guid,
          "author"     => author_id,
          "created_at" => "2015-01-01T22:37:29Z"
        },
        "entity_type" => "reshare"
      }
    }

    it "is not valid" do
      expect(validator.valid?).to be_falsey
      expect(validator.messages).to include("reshare Reshare:#{guid} doesn't have a root, ignored")
    end
  end
end
