# frozen_string_literal: true

describe ContactRetraction do
  let(:contact) { FactoryGirl.build(:contact, sharing: true, receiving: true) }
  let(:retraction) { ContactRetraction.for(contact) }

  describe "#subscribers" do
    it "contains the contact person" do
      expect(retraction.subscribers).to eq([contact.person])
    end
  end

  describe "#data" do
    it "contains the hash with all data from the federation-retraction" do
      federation_retraction_data = Diaspora::Federation::Entities.contact(contact).to_h
      federation_retraction_data[:sharing] = false
      federation_retraction_data[:following] = false

      expect(retraction.data).to eq(federation_retraction_data)
    end
  end

  describe ".retraction_data_for" do
    it "creates a retraction for a contact" do
      contact = FactoryGirl.build(:contact, sharing: false, receiving: false)
      expect(Diaspora::Federation::Entities).to receive(:contact).with(contact).and_call_original
      data = ContactRetraction.retraction_data_for(contact)

      expect(data[:author]).to eq(contact.user.diaspora_handle)
      expect(data[:recipient]).to eq(contact.person.diaspora_handle)
      expect(data[:sharing]).to be_falsey
      expect(data[:following]).to be_falsey
    end
  end

  describe ".for" do
    it "creates a retraction for a contact" do
      expect(ContactRetraction).to receive(:retraction_data_for).with(contact)
      ContactRetraction.for(contact)
    end

    it "create contact entity with 'sharing' and 'following' set to false" do
      data = ContactRetraction.for(contact).data
      expect(data[:sharing]).to be_falsey
      expect(data[:following]).to be_falsey
    end
  end

  describe ".defer_dispatch" do
    it "queues a job to send the retraction later" do
      contact = FactoryGirl.build(:contact, user: local_luke, person: remote_raphael)
      retraction = ContactRetraction.for(contact)
      federation_retraction_data = Diaspora::Federation::Entities.contact(contact).to_h

      expect(Workers::DeferredRetraction).to receive(:perform_async).with(
        local_luke.id, "ContactRetraction", federation_retraction_data, [remote_raphael.id], {}
      )

      retraction.defer_dispatch(local_luke)
    end
  end

  describe "#public?" do
    it "returns false for a contact retraction" do
      expect(retraction.public?).to be_falsey
    end
  end
end
