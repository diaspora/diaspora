# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::PostsValidator do
  include_context "validators shared context"
  include_context "with known author"

  let(:correct_item) {
    status_message = FactoryGirl.create(:status_message)
    {
      "entity_data" => {
        "guid"        => UUID.generate(:compact),
        "author"      => author_id,
        "root_author" => status_message.author.diaspora_handle,
        "root_guid"   => status_message.guid,
        "created_at"  => "2015-01-01T22:37:29Z"
      },
      "entity_type" => "reshare"
    }
  }

  let(:correct_archive) {
    {
      user: {
        posts: [correct_item]
      }
    }
  }

  let(:incorrect_item) {
    {
      "entity_data" => {
        "guid"       => UUID.generate(:compact),
        "author"     => author_id,
        "created_at" => "2015-01-01T22:37:29Z"
      },
      "entity_type" => "reshare"
    }
  }

  let(:archive_with_error) {
    {
      user: {
        posts: [correct_item, incorrect_item]
      }
    }
  }

  let(:element_validator_class) {
    ArchiveValidator::PostValidator
  }

  include_examples "a collection validator"
end
