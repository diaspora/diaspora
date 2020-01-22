# frozen_string_literal: true

describe AspectsMembershipService do
  before do
    @alice_aspect1  = alice.aspects.first
    @alice_aspect2  = alice.aspects.create(name: "another aspect")
    @bob_aspect1 = bob.aspects.first
  end

  describe "#create" do
    context "with valid IDs" do
      it "succeeds" do
        membership = aspects_membership_service.create(@alice_aspect2.id, bob.person.id)
        expect(membership[:aspect_id]).to eq(@alice_aspect2.id)
        expect(@alice_aspect2.contacts.find_by(person_id: bob.person.id)).not_to be_nil
      end

      it "fails if already in aspect" do
        aspects_membership_service.create(@alice_aspect2.id, bob.person.id)
        expect {
          aspects_membership_service.create(@alice_aspect2.id, bob.person.id)
        }.to raise_error ActiveRecord::RecordNotUnique
      end
    end

    context "with invalid IDs" do
      it "fails with invalid User ID" do
        expect {
          aspects_membership_service.create(@alice_aspect2.id, -1)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "fails with invalid Aspect ID" do
        expect {
          aspects_membership_service.create(-1, bob.person.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "fails with aspect ID that isn't user's" do
        expect {
          aspects_membership_service.create(@bob_aspect1.id, eve.person.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "#destroy" do
    before do
      @membership = aspects_membership_service.create(@alice_aspect2.id, bob.person.id)
    end

    context "with aspect/user valid IDs" do
      it "succeeds if in aspect" do
        aspects_membership_service.destroy_by_ids(@alice_aspect2.id, bob.person.id)
        expect(@alice_aspect2.contacts.find_by(person_id: bob.person.id)).to be_nil
      end

      it "fails if not in aspect" do
        expect {
          aspects_membership_service.destroy_by_ids(@alice_aspect2.id, eve.person.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "with a membership ID" do
      it "succeeds if their membership" do
        aspects_membership_service.destroy_by_membership_id(@membership.id)
        expect(@alice_aspect2.contacts.find_by(person_id: bob.person.id)).to be_nil
      end

      it "fails if not their membership" do
        expect {
          aspects_membership_service(eve).destroy_by_membership_id(@membership.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "fails if invalid membership ID" do
        expect {
          aspects_membership_service(eve).destroy_by_membership_id(-1)
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "with invalid IDs" do
      it "fails with invalid User ID" do
        expect {
          aspects_membership_service.destroy_by_ids(@alice_aspect2.id, -1)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "fails with invalid Aspect ID" do
        expect {
          aspects_membership_service.destroy_by_ids(-1, eve.person.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "fails with aspect ID that isn't user's" do
        expect {
          aspects_membership_service(eve).destroy_by_ids(@alice_aspect2.id, bob.person.id)
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "#list" do
    before do
      aspects_membership_service.create(@alice_aspect2.id, bob.person.id)
      aspects_membership_service.create(@alice_aspect2.id, eve.person.id)
      @alice_aspect3 = alice.aspects.create(name: "empty aspect")
    end

    context "with valid aspect ID" do
      it "returns users in full aspect" do
        contacts = aspects_membership_service.contacts_in_aspect(@alice_aspect2.id)
        expect(contacts.length).to eq(2)
        expect(contacts.map {|c| c.person.guid }.sort).to eq([bob.person.guid, eve.person.guid].sort)
      end

      it "returns empty array in empty aspect" do
        contacts = aspects_membership_service.contacts_in_aspect(@alice_aspect3.id)
        expect(contacts.length).to eq(0)
      end
    end

    context "with invalid aspect ID" do
      it "fails" do
        expect {
          aspects_membership_service.contacts_in_aspect(-1)
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "#all_contacts" do
    before do
      aspects_membership_service.create(@alice_aspect2.id, bob.person.id)
      aspects_membership_service.create(@alice_aspect2.id, eve.person.id)
      @alice_aspect3 = alice.aspects.create(name: "empty aspect")
    end

    it "returns all user's contacts" do
      contacts = aspects_membership_service.all_contacts
      expect(contacts.length).to eq(2)
    end
  end

  def aspects_membership_service(user=alice)
    AspectsMembershipService.new(user)
  end
end
