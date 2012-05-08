#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Relayable do
  shared_examples_for "it is relayable" do

    describe 'interacted_at' do
      it 'sets the interacted at of the parent to the created at of the relayable post' do
        Timecop.freeze Time.now do
          relayable = build_object
          relayable.save
          if relayable.parent.respond_to?(:interacted_at) #I'm sorry.
            relayable.parent.interacted_at.to_i.should == relayable.created_at.to_i
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
            @relayable.should_not be_valid
            @relayable.should have(1).error_on(:author_id)
          end

          it "sends a retraction for the object" do
            pending 'need to figure out how to test this'
            RelayableRetraction.should_receive(:build)
            Postzord::Dispatcher.should_receive(:build)
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
            relayable.should be_valid
          end
        end
      end
    end

    context 'encryption' do
      describe '#parent_author_signature' do
        it 'should sign the object if the user is the post author' do
          @object_by_parent_author.verify_parent_author_signature.should be_true
        end

        it 'does not sign as the parent author is not parent' do
          @object_by_recipient.author_signature = @object_by_recipient.send(:sign_with_key, @local_leia.encryption_key)
          @object_by_recipient.verify_parent_author_signature.should be_false
        end

        it 'should verify a object made on a remote post by a different contact' do
          @object_by_recipient.author_signature = @object_by_recipient.send(:sign_with_key, @local_leia.encryption_key)
          @object_by_recipient.parent_author_signature = @object_by_recipient.send(:sign_with_key, @local_luke.encryption_key)
          @object_by_recipient.verify_parent_author_signature.should be_true
        end
      end

      describe '#author_signature' do
        it 'should sign as the object author' do
          @object_on_remote_parent.signature_valid?.should be_true
          @object_by_parent_author.signature_valid?.should be_true
          @object_by_recipient.signature_valid?.should be_true
        end
      end
    end

    context 'propagation' do
      describe '#receive' do
        it 'does not overwrite a object that is already in the db' do
          expect {
            @dup_object_by_parent_author.receive(@local_leia, @local_luke.person)
          }.to_not change { @dup_object_by_parent_author.class.count }
        end

        it 'does not process if post_creator_signature is invalid' do
          @object_by_parent_author.delete # remove object from db so we set a creator sig
          @dup_object_by_parent_author.parent_author_signature = "dsfadsfdsa"
          @dup_object_by_parent_author.receive(@local_leia, @local_luke.person).should == nil
        end

        it 'signs when the person receiving is the parent author' do
          @object_by_recipient.save
          @object_by_recipient.receive(@local_luke, @local_leia.person)
          @object_by_recipient.reload.parent_author_signature.should_not be_blank
        end

        it 'dispatches when the person receiving is the parent author' do
          p = Postzord::Dispatcher.build(@local_luke, @object_by_recipient)
          p.should_receive(:post)
          p.class.stub!(:new).and_return(p)
          @object_by_recipient.receive(@local_luke, @local_leia.person)
        end

        it 'calls after_receive callback' do
          @object_by_recipient.should_receive(:after_receive)
          @object_by_recipient.class.stub(:where).and_return([@object_by_recipient])
          @object_by_recipient.receive(@local_luke, @local_leia.person)
        end
      end

      describe '#subscribers' do
        it 'returns the posts original audience, if the post is owned by the user' do
          @object_by_parent_author.subscribers(@local_luke).map(&:id).should =~ [@local_leia.person, @remote_raphael].map(&:id)
        end

        it 'returns the owner of the original post, if the user owns the object' do
          @object_by_recipient.subscribers(@local_leia).map(&:id).should =~ [@local_luke.person].map(&:id)
        end
      end
    end
  end
end

