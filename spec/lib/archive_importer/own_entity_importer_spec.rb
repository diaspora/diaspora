# frozen_string_literal: true

require "lib/archive_importer/own_entity_importer_shared"

describe ArchiveImporter::OwnEntityImporter do
  it_behaves_like "own entity importer" do
    let(:entity_class) { StatusMessage }
    let!(:status_message) { FactoryGirl.create(:status_message) }
    let(:entity) { Diaspora::Federation::Entities.build(status_message) }

    let(:known_entity_with_correct_author) {
      entity.to_json
    }

    let(:known_entity_with_incorrect_author) {
      result = known_entity_with_correct_author
      result[:entity_data][:author] = FactoryGirl.create(:person).diaspora_handle
      result
    }

    let(:unknown_entity) {
      result = known_entity_with_correct_author
      result[:entity_data][:author] = Fabricate.sequence(:diaspora_id)
      result[:entity_data][:guid] = UUID.generate(:compact)
      result
    }
  end
end
