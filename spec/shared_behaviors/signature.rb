# frozen_string_literal: true

shared_examples_for "signature data" do
  let(:relayable) { FactoryGirl.create(relayable_type) }
  let(:signature) {
    described_class.new(
      relayable_type    => relayable,
      :author_signature => "signature",
      :additional_data  => {"additional_data" => "some data"},
      :signature_order  => SignatureOrder.new(order: "author guid parent_guid")
    )
  }

  describe "#order" do
    it "it returns the order as array" do
      expect(signature.order).to eq(%w(author guid parent_guid))
    end
  end

  describe "#additional_data" do
    it "is stored as hash" do
      signature.save

      entity = described_class.reflect_on_association(relayable_type).klass.find(relayable.id)
      expect(entity.signature.additional_data).to eq("additional_data" => "some data")
    end

    it "can be missing" do
      signature.additional_data = nil
      signature.save

      entity = described_class.reflect_on_association(relayable_type).klass.find(relayable.id)
      expect(entity.signature.additional_data).to eq({})
    end
  end

  context "validation" do
    it "is valid" do
      expect(signature).to be_valid
    end

    it "requires a linked relayable" do
      signature.public_send("#{relayable_type}=", nil)
      expect(signature).not_to be_valid
    end

    it "requires a signature_order" do
      signature.signature_order = nil
      expect(signature).not_to be_valid
    end

    it "requires a author_signature" do
      signature.author_signature = nil
      expect(signature).not_to be_valid
    end
  end
end
