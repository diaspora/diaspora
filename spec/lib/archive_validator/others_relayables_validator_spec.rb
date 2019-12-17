# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::OthersRelayablesValidator do
  include_context "validators shared context"
  include_context "with known author"

  let(:parent_guid) { UUID.generate :compact }
  before do
    include_in_input_archive(
      user: {
        posts: [
          {
            entity_type:          "status_message",
            subscribed_users_ids: [],
            entity_data:          {
              text:   "test",
              author: author_id,
              public: false,
              guid:   parent_guid
            }
          }
        ]
      }
    )
  end

  let(:correct_item) {
    {
      "entity_type" => "like",
      "entity_data" => {
        "positive"    => true,
        "parent_type" => "Post",
        "author"      => "test-1@example.com",
        "parent_guid" => parent_guid,
        "guid"        => UUID.generate(:compact)
      }
    }
  }

  let(:correct_archive) {
    {
      others_data: {
        relayables: [correct_item]
      }
    }
  }

  let(:incorrect_item) {
    {
      "entity_type" => "like",
      "entity_data" => {
        "positive"    => true,
        "parent_type" => "Post",
        "author"      => "test-1@example.com",
        "parent_guid" => UUID.generate(:compact),
        "guid"        => UUID.generate(:compact)
      }
    }
  }

  let(:archive_with_error) {
    {
      others_data: {
        relayables: [correct_item, incorrect_item]
      }
    }
  }

  let(:element_validator_class) {
    ArchiveValidator::RelayableValidator
  }

  include_examples "a collection validator"
end
