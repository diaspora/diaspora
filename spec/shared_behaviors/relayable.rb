#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Relayable do
  shared_examples_for "it is relayable" do
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
          lambda{
            @dup_object_by_parent_author.receive(@local_leia, @local_luke.person)
          }.should_not change(@dup_object_by_parent_author.class, :count)
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
          p = Postzord::Dispatch.new(@local_luke, @object_by_recipient)
          p.should_receive(:post)
          Postzord::Dispatch.stub!(:new).and_return(p)
          @object_by_recipient.receive(@local_luke, @local_leia.person)
        end

        it 'sockets to the user' do
          pending
          @object_by_recipient.should_receive(:socket_to_user).exactly(3).times
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

