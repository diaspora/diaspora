# frozen_string_literal: true

describe ArchiveImporter::BlockImporter do
  let(:target) { FactoryBot.create(:user) }

  describe "#import" do
    it "adds a block entry to the user" do
      person_to_block = FactoryBot.create(:person)
      block_importer = ArchiveImporter::BlockImporter.new(person_to_block.diaspora_handle, target)
      block_importer.import

      expect(target.blocks.count).to eq(1)
      expect(target.blocks.first.person_id).to eq(person_to_block.id)
    end

    it "handles unfetchable person to block" do
      expect_any_instance_of(DiasporaFederation::Discovery::Discovery).to receive(:fetch_and_save).and_raise(
        DiasporaFederation::Discovery::DiscoveryError, "discovery error reasons"
      )

      block_importer = ArchiveImporter::BlockImporter.new("unknown_person@bad_pod.tld", target)
      block_importer.import

      expect(target.blocks).to be_empty
    end
  end
end
