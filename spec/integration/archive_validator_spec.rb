# frozen_string_literal: true

require "integration/archive_shared"

describe ArchiveValidator do
  let(:json_file) { StringIO.new(json_string) }
  let(:archive_validator) { ArchiveValidator.new(json_file) }

  context "without known archive author" do
    let(:private_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:archive_author) { "user@oldpod.tld" }
    let(:json_string) { <<~JSON }
      {
        "user": {
          "username": "old_user",
          "email": "mail@example.com",
          "private_key": #{private_key.export.dump},
          "profile": {
            "entity_type": "profile",
            "entity_data": {
              "author": "#{archive_author}"
            }
          },
          "contacts": [],
          "contact_groups": [],
          "post_subscriptions": [],
          "posts": [],
          "relayables": []
        },
        "others_data": {
          "relayables": []
        },
        "version": "2.0"
      }
    JSON

    it "fetches author" do
      expect_person_fetch(archive_author, private_key.public_key.export)

      archive_validator.validate
      expect(archive_validator.warnings).to be_empty
      expect(archive_validator.errors).to be_empty
    end
  end

  context "when archive doesn't contain mandatory data" do
    let(:json_string) { {}.to_json }

    it "contains error" do
      archive_validator.validate
      expect(archive_validator.errors).to include('Missing mandatory data: key not found: "user"')
    end
  end
end
