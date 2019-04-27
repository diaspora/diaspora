# frozen_string_literal: true

describe ArchiveImporter::ContactImporter do
  let(:target) { FactoryGirl.create(:user) }
  let(:contact_importer) { described_class.new(import_object, target) }

  describe "#import" do
    context "with duplicating data" do
      let(:contact) { DataGenerator.new(target).mutual_friend.person.contacts.first }
      let(:import_object) {
        {
          "person_guid"               => contact.person.guid,
          "account_id"                => contact.person.diaspora_handle,
          "receiving"                 => contact.receiving,
          "public_key"                => contact.person.serialized_public_key,
          "person_name"               => contact.person.full_name,
          "followed"                  => contact.receiving,
          "sharing"                   => contact.sharing,
          "contact_groups_membership" => [
            contact.aspects.first.name
          ],
          "following"                 => contact.sharing
        }
      }

      it "doesn't fail" do
        expect {
          contact_importer.import
        }.not_to raise_error

        expect(target.contacts.count).to eq(1)
      end
    end

    context "with correct data" do
      let(:aspect) { FactoryGirl.create(:aspect, user: target) }
      let(:person) { FactoryGirl.create(:person) }
      let(:import_object) {
        {
          "person_guid"               => person.guid,
          "account_id"                => person.diaspora_handle,
          "receiving"                 => true,
          "public_key"                => person.serialized_public_key,
          "person_name"               => person.full_name,
          "followed"                  => true,
          "sharing"                   => true,
          "contact_groups_membership" => [
            aspect.name
          ],
          "following"                 => true
        }
      }

      it "imports the contact" do
        expect {
          contact_importer.import
        }.to change(Contact, :count).by(1)

        contact = target.contacts.first
        expect(contact).not_to be_nil
        expect(contact.person).to eq(person)
        expect(contact.aspects).to eq([aspect])
      end
    end
  end
end
