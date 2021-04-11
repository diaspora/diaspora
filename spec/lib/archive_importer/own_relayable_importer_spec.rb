# frozen_string_literal: true

require "lib/archive_importer/own_entity_importer_shared"

describe ArchiveImporter::OwnRelayableImporter do
  it_behaves_like "own entity importer" do
    let(:entity_class) { Comment }
    let!(:comment) { FactoryBot.create(:comment, author: FactoryBot.create(:user).person) }

    let(:known_entity_with_correct_author) {
      Diaspora::Federation::Entities.build(comment).to_json
    }

    let(:known_entity_with_incorrect_author) {
      Fabricate(
        :comment_entity,
        author:      FactoryBot.create(:user).diaspora_handle,
        guid:        comment.guid,
        parent_guid: comment.parent.guid
      ).to_json
    }

    let(:unknown_entity) {
      Fabricate(
        :comment_entity,
        author:      FactoryBot.create(:user).diaspora_handle,
        parent_guid: FactoryBot.create(:status_message).guid
      ).to_json
    }
  end
end
