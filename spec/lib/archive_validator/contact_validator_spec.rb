# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::ContactValidator do
  include_context "validators shared context"
  include_context "with known author"

  let(:validator) { described_class.new(input_hash, contact) }

  before do
    include_in_input_archive(
      user: {
        contacts: [contact]
      }
    )
  end

  context "with a correct contact" do
    let(:known_id) { FactoryGirl.create(:person).diaspora_handle }

    before do
      include_in_input_archive(
        user: {contact_groups: [{name: "generic"}]}
      )
    end

    let(:contact) {
      {
        "account_id"                => known_id,
        "contact_groups_membership" => ["generic"]
      }
    }

    include_examples "validation result is valid"
  end

  context "when person referenced in contact is unknown" do
    let(:unknown_id) { Fabricate.sequence(:diaspora_id) }

    let(:contact) {
      {
        "account_id" => unknown_id
      }
    }

    context "and discovery is successful" do
      before do
        expect_any_instance_of(DiasporaFederation::Discovery::Discovery).to receive(:fetch_and_save) {
          FactoryGirl.create(:person, diaspora_handle: unknown_id)
        }
      end

      include_examples "validation result is valid"
    end

    context "and discovery fails" do
      before do
        expect_any_instance_of(DiasporaFederation::Discovery::Discovery)
          .to receive(:fetch_and_save).and_raise(
            DiasporaFederation::Discovery::DiscoveryError, "discovery error reasons"
          )
      end

      it "is not valid" do
        expect(validator.valid?).to be_falsey
        expect(validator.messages).to include(
          "ArchiveValidator::ContactValidator: failed to fetch person #{unknown_id}: discovery error reasons"
        )
      end
    end
  end

  context "when person is deleted" do
    let(:person) { FactoryGirl.create(:person) }
    let(:diaspora_id) { person.diaspora_handle }

    let(:contact) {
      {
        "account_id"                => diaspora_id,
        "contact_groups_membership" => ["generic"]
      }
    }

    before do
      AccountDeleter.new(person).perform!
    end

    it "is not valid" do
      expect(validator.valid?).to be_falsey
      expect(validator.messages).to include(
        "ArchiveValidator::ContactValidator: account #{diaspora_id} is closed"
      )
    end
  end

  context "when person is migrated" do
    let(:account_migration) { FactoryGirl.create(:account_migration).tap(&:perform!) }
    let(:person) { account_migration.old_person }
    let(:diaspora_id) { person.diaspora_handle }

    let(:contact) {
      {
        "account_id"                => diaspora_id,
        "contact_groups_membership" => ["generic"]
      }
    }

    it "is valid and person reference is updated" do
      expect(validator.valid?).to be_truthy
      expect(contact["account_id"]).to eq(account_migration.new_person.diaspora_handle)
      expect(validator.messages).to be_empty
    end
  end
end
