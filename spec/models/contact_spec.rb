#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Contact, type: :model do
  describe "aspect_memberships" do
    it "deletes dependent aspect memberships" do
      expect {
        alice.contact_for(bob.person).destroy
      }.to change(AspectMembership, :count).by(-1)
    end
  end

  context "validations" do
    let(:contact) { Contact.new }

    it "is valid" do
      expect(alice.contact_for(bob.person)).to be_valid
    end

    it "requires a user" do
      contact.valid?
      expect(contact.errors.full_messages).to include "User can't be blank"
    end

    it "requires a person" do
      contact.valid?
      expect(contact.errors.full_messages).to include "Person can't be blank"
    end

    it "validates uniqueness" do
      person = FactoryGirl.create(:person)

      contact1 = alice.contacts.create(person: person)
      expect(contact1).to be_valid

      contact2 = alice.contacts.create(person: person)
      expect(contact2).not_to be_valid
    end

    describe "#not_contact_with_closed_account" do
      it "adds error if the person's account is closed" do
        person = FactoryGirl.create(:person, closed_account: true)
        bad_contact = alice.contacts.create(person: person)

        expect(bad_contact).not_to be_valid
        expect(bad_contact.errors.full_messages.count).to eq(1)
        expect(bad_contact.errors.full_messages.first).to eq("Cannot be in contact with a closed account")
      end
    end

    describe "#not_contact_for_self" do
      it "adds error contacting self" do
        bad_contact = alice.contacts.create(person: alice.person)

        expect(bad_contact).not_to be_valid
        expect(bad_contact.errors.full_messages.count).to eq(1)
        expect(bad_contact.errors.full_messages.first).to eq("Cannot create self-contact")
      end
    end

    describe "#not_blocked_user" do
      it "adds an error when start sharing with a blocked person" do
        alice.blocks.create(person: eve.person)
        bad_contact = alice.contacts.create(person: eve.person, receiving: true)

        expect(bad_contact).not_to be_valid
        expect(bad_contact.errors.full_messages.count).to eq(1)
        expect(bad_contact.errors.full_messages.first).to eq("Cannot connect to an ignored user")
      end

      it "is valid when a blocked person starts sharing with the user" do
        alice.blocks.create(person: eve.person)
        bad_contact = alice.contacts.create(person: eve.person, receiving: false, sharing: true)

        expect(bad_contact).to be_valid
      end
    end
  end

  context "scope" do
    describe "sharing" do
      it "returns contacts with sharing true" do
        expect {
          alice.contacts.create!(sharing: true, person: FactoryGirl.create(:person))
        }.to change {
          Contact.sharing.count
        }.by(1)

        expect {
          alice.contacts.create!(sharing: false, person: FactoryGirl.create(:person))
        }.to change {
          Contact.sharing.count
        }.by(0)
      end
    end

    describe "receiving" do
      it "returns contacts with sharing true" do
        expect {
          alice.contacts.create!(receiving: true, person: FactoryGirl.build(:person))
        }.to change {
          Contact.receiving.count
        }.by(1)

        expect {
          alice.contacts.create!(receiving: false, person: FactoryGirl.build(:person))
        }.to change {
          Contact.receiving.count
        }.by(0)
      end
    end

    describe "mutual" do
      it "returns contacts with sharing true and receiving true" do
        expect {
          alice.contacts.create!(receiving: true, sharing: true, person: FactoryGirl.build(:person))
        }.to change {
          Contact.mutual.count
        }.by(1)

        expect {
          alice.contacts.create!(receiving: false, sharing: true, person: FactoryGirl.build(:person))
          alice.contacts.create!(receiving: true, sharing: false, person: FactoryGirl.build(:person))
        }.to change {
          Contact.mutual.count
        }.by(0)
      end
    end

    describe "only_sharing" do
      it "returns contacts with sharing true and receiving false" do
        expect {
          alice.contacts.create!(receiving: false, sharing: true, person: FactoryGirl.build(:person))
          alice.contacts.create!(receiving: false, sharing: true, person: FactoryGirl.build(:person))
        }.to change {
          Contact.only_sharing.count
        }.by(2)

        expect {
          alice.contacts.create!(receiving: true, sharing: true, person: FactoryGirl.build(:person))
          alice.contacts.create!(receiving: true, sharing: false, person: FactoryGirl.build(:person))
        }.to change {
          Contact.only_sharing.count
        }.by(0)
      end
    end

    describe "all_contacts_of_person" do
      it "returns all contacts where the person is the passed in person" do
        person = FactoryGirl.create(:person)

        contact1 = FactoryGirl.create(:contact, person: person)
        FactoryGirl.create(:contact) # contact2

        expect(Contact.all_contacts_of_person(person)).to eq([contact1])
      end
    end
  end

  describe "#contacts" do
    before do
      bob.aspects.create(name: "next")
      bob.aspects(true)

      @original_aspect = bob.aspects.where(name: "generic").first
      @new_aspect = bob.aspects.where(name: "next").first

      @people1 = []
      @people2 = []

      1.upto(5) do
        person = FactoryGirl.build(:person)
        bob.contacts.create(person: person, aspects: [@original_aspect])
        @people1 << person
      end
      1.upto(5) do
        person = FactoryGirl.build(:person)
        bob.contacts.create(person: person, aspects: [@new_aspect])
        @people2 << person
      end
      # eve <-> bob <-> alice
    end

    context "on a contact for a local user" do
      before do
        alice.reload
        alice.aspects.reload
        @contact = alice.contact_for(bob.person)
      end

      it "returns the target local user's contacts that are in the same aspect" do
        expect(@contact.contacts.map(&:id)).to match_array([eve.person].concat(@people1).map(&:id))
      end

      it "returns nothing if contacts_visible is false in that aspect" do
        @original_aspect.contacts_visible = false
        @original_aspect.save
        expect(@contact.contacts).to eq([])
      end

      it "returns no duplicate contacts" do
        [alice, eve].each {|c| bob.add_contact_to_aspect(bob.contact_for(c.person), bob.aspects.last) }
        contact_ids = @contact.contacts.map(&:id)
        expect(contact_ids.uniq).to eq(contact_ids)
      end
    end

    context "on a contact for a remote user" do
      let(:contact) { bob.contact_for @people1.first }

      it "returns an empty array" do
        expect(contact.contacts).to eq([])
      end
    end
  end

  describe "#receive" do
    it "shares back if auto_following is enabled" do
      alice.auto_follow_back = true
      alice.auto_follow_back_aspect = alice.aspects.first
      alice.save

      expect(alice).to receive(:share_with).with(eve.person, alice.aspects.first)

      described_class.new(user: alice, person: eve.person, sharing: true).receive([alice.id])
    end

    it "shares not back if auto_following is not enabled" do
      alice.auto_follow_back = false
      alice.auto_follow_back_aspect = alice.aspects.first
      alice.save

      expect(alice).not_to receive(:share_with)

      described_class.new(user: alice, person: eve.person, sharing: true).receive([alice.id])
    end

    it "shares not back if already sharing" do
      alice.auto_follow_back = true
      alice.auto_follow_back_aspect = alice.aspects.first
      alice.save

      expect(alice).not_to receive(:share_with)

      described_class.new(user: alice, person: eve.person, sharing: true, receiving: true).receive([alice.id])
    end
  end

  describe "#object_to_receive" do
    it "returns the contact for the recipient" do
      user = FactoryGirl.create(:user)
      contact = alice.contacts.create(person: user.person)
      receive = contact.object_to_receive
      expect(receive.user).to eq(user)
      expect(receive.person).to eq(alice.person)
    end
  end

  describe "#subscribers" do
    it "returns an array with recipient of the contact" do
      contact = alice.contacts.create(person: eve.person)
      expect(contact.subscribers).to match_array([eve.person])
    end
  end
end
