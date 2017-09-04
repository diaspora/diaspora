# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

shared_examples_for "it is relayable" do
  describe "validations" do
    context "author ignored by parent author" do
      context "the author is on the parent object author's ignore list when object is created" do
        before do
          bob.blocks.create(person: alice.person)
        end

        it "is invalid" do
          expect(relayable).not_to be_valid
          expect(relayable.errors[:author_id].size).to eq(1)
        end

        it "works if the object has no parent" do # This can happen if we get a comment for a post that's been deleted
          relayable.parent = nil
          expect { relayable.valid? }.to_not raise_exception
        end
      end

      context "the author is added to the parent object author's ignore list later" do
        it "is valid" do
          relayable.save!
          bob.blocks.create(person: alice.person)
          expect(relayable).to be_valid
        end
      end
    end
  end

  describe "#subscribers" do
    context "parent is local" do
      it "returns the parents original audience, if author is local" do
        expect(object_on_local_parent.subscribers.map(&:id))
          .to match_array([local_leia.person, remote_raphael].map(&:id))
      end

      it "returns remote persons of the parents original audience not on same pod as the author, if author is remote" do
        person1 = FactoryGirl.create(:person, pod: remote_raphael.pod)
        person2 = FactoryGirl.create(:person, pod: FactoryGirl.create(:pod))
        local_luke.share_with(person1, local_luke.aspects.first)
        local_luke.share_with(person2, local_luke.aspects.first)

        expect(remote_object_on_local_parent.subscribers.map(&:id)).to match_array([person2].map(&:id))
      end
    end

    context "parent is remote" do
      it "returns the author of parent and author of relayable (for local delivery)" do
        expect(object_on_remote_parent.subscribers.map(&:id))
          .to match_array([remote_raphael, local_luke.person].map(&:id))
      end
    end
  end

  describe "#signature" do
    let(:signature_class) { described_class.reflect_on_association(:signature).klass }

    before do
      remote_object_on_local_parent.signature = signature_class.new(
        author_signature: "signature",
        additional_data:  {"new_property" => "some text"},
        signature_order:  FactoryGirl.create(:signature_order)
      )
    end

    it "returns the signature data" do
      signature = described_class.find(remote_object_on_local_parent.id).signature
      expect(signature).not_to be_nil
      expect(signature.author_signature).to eq("signature")
      expect(signature.additional_data).to eq("new_property" => "some text")
      expect(signature.order).to eq(%w(guid parent_guid text author))
    end

    it "deletes the signature when destroying the relayable" do
      id = remote_object_on_local_parent.id
      remote_object_on_local_parent.destroy!

      signature = signature_class.find_by(signature_class.primary_key => id)
      expect(signature).to be_nil
    end
  end
end
