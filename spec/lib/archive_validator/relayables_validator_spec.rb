# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::RelayablesValidator do
  include_context "validators shared context"
  include_context "with known author"

  let(:parent_guid) { FactoryGirl.create(:status_message).guid }
  let(:not_found_guid) {
    UUID.generate(:compact).tap {|guid|
      stub_request(:get, "http://example.net/fetch/post/#{guid}").to_return(status: 404)
    }
  }

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
      user: {
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
        "parent_guid" => not_found_guid,
        "guid"        => UUID.generate(:compact)
      }
    }
  }

  let(:archive_with_error) {
    {
      user: {
        relayables: [correct_item, incorrect_item]
      }
    }
  }

  let(:element_validator_class) {
    ArchiveValidator::OwnRelayableValidator
  }

  include_examples "a collection validator"
end
