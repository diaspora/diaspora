# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::ContactsValidator do
  include_context "validators shared context"
  include_context "with known author"

  let(:correct_item) {
    person = FactoryGirl.create(:person)
    {
      "contact_groups_membership" => [],
      "person_guid"               => person.guid,
      "public_key"                => person.serialized_public_key,
      "followed"                  => false,
      "receiving"                 => false,
      "sharing"                   => true,
      "person_name"               => person.name,
      "following"                 => true,
      "account_id"                => person.diaspora_handle
    }
  }

  let(:correct_archive) {
    {
      "user" => {
        "contacts" => [correct_item]
      }
    }
  }

  let(:incorrect_item) {
    person = FactoryGirl.create(:person)
    person.lock_access!
    {
      "contact_groups_membership" => [],
      "person_guid"               => person.guid,
      "public_key"                => person.serialized_public_key,
      "followed"                  => false,
      "receiving"                 => false,
      "sharing"                   => true,
      "person_name"               => person.name,
      "following"                 => true,
      "account_id"                => person.diaspora_handle
    }
  }

  let(:archive_with_error) {
    {
      "user" => {
        "contacts" => [correct_item, incorrect_item]
      }
    }
  }

  let(:element_validator_class) {
    ArchiveValidator::ContactValidator
  }

  include_examples "a collection validator"
end
