#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

shared_examples_for "it is relayable" do

  describe 'interacted_at' do
    it 'sets the interacted at of the parent to the created at of the relayable post' do
      Timecop.freeze Time.now do
        relayable = build_object
        relayable.save
        if relayable.parent.respond_to?(:interacted_at) #I'm sorry.
          expect(relayable.parent.interacted_at.to_i).to eq(relayable.created_at.to_i)
        end
      end
    end
  end

  describe 'validations' do
    describe 'on :author_id' do
      context "the author is on the parent object author's ignore list when object is created" do
        before do
          bob.blocks.create(:person => alice.person)
          @relayable = build_object
        end

        it "is invalid" do
          expect(@relayable).not_to be_valid
          expect(@relayable.errors[:author_id].size).to eq(1)
        end

        it "sends a retraction for the object" do
          skip 'need to figure out how to test this'
          expect(Retraction).to receive(:for)
          @relayable.valid?
        end

        it "works if the object has no parent" do # This can happen if we get a comment for a post that's been deleted
          @relayable.parent = nil
          expect { @relayable.valid? }.to_not raise_exception
        end
      end

      context "the author is added to the parent object author's ignore list later" do
        it "is valid" do
          relayable = build_object
          relayable.save!
          bob.blocks.create(:person => alice.person)
          expect(relayable).to be_valid
        end
      end
    end
  end

  context 'encryption' do
    describe '#parent_author_signature' do
      it 'should sign the object if the user is the post author' do
        expect(@object_by_parent_author.verify_parent_author_signature).to be true
      end

      it 'should verify a object made on a remote post by a different contact' do
        @object_by_recipient.author_signature = @object_by_recipient.send(:sign_with_key, @local_leia.encryption_key)
        @object_by_recipient.parent_author_signature = @object_by_recipient.send(:sign_with_key, @local_luke.encryption_key)
        expect(@object_by_recipient.verify_parent_author_signature).to be true
      end
    end

    describe '#author_signature' do
      it 'should sign as the object author' do
        expect(@object_on_remote_parent.signature_valid?).to be true
        expect(@object_by_parent_author.signature_valid?).to be true
        expect(@object_by_recipient.signature_valid?).to be true
      end
    end
  end

  context 'propagation' do
    describe '#receive' do
      it 'dispatches when the person receiving is the parent author' do
        skip # TODO
        p = Postzord::Dispatcher.build(@local_luke, @object_by_recipient)
        expect(p).to receive(:post)
        allow(p.class).to receive(:new).and_return(p)
        @object_by_recipient.receive(@local_luke, @local_leia.person)
      end
    end

    describe '#subscribers' do
      it 'returns the posts original audience, if the post is owned by the user' do
        expect(@object_by_parent_author.subscribers.map(&:id))
          .to match_array([@local_leia.person, @remote_raphael].map(&:id))
      end

      it 'returns the owner of the original post, if the user owns the object' do
        skip # TODO
        expect(@object_by_recipient.subscribers.map(&:id)).to match_array([@local_luke.person].map(&:id))
      end
    end
  end
end

