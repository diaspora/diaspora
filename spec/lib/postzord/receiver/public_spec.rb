#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Postzord::Receiver::Public do
  before do
    @post = FactoryGirl.build(:status_message, :author => alice.person, :public => true)
    @created_salmon = Salmon::Slap.create_by_user_and_activity(alice, @post.to_diaspora_xml)
    @xml = @created_salmon.xml_for(nil)
  end

  context 'round trips works with' do
    it 'a comment' do
      sm = FactoryGirl.create(:status_message, :author => alice.person)

      comment = bob.build_comment(:text => 'yo', :post => sm)
      comment.save
      #bob signs his comment, and then sends it up
      xml = Salmon::Slap.create_by_user_and_activity(bob, comment.to_diaspora_xml).xml_for(nil)
      bob.destroy
      comment.destroy
      expect{
        receiver = Postzord::Receiver::Public.new(xml)
        receiver.perform!
      }.to change(Comment, :count).by(1)
    end
  end

  describe '#initialize' do
    it 'creates a Salmon instance variable' do
      receiver = Postzord::Receiver::Public.new(@xml)
      expect(receiver.salmon).not_to be_nil
    end
  end

  describe '#perform!' do
    before do
      @receiver = Postzord::Receiver::Public.new(@xml)
    end

    it 'calls verify_signature' do
      expect(@receiver).to receive(:verified_signature?)
      @receiver.perform!
    end

    it 'returns false if signature is not verified' do
      expect(@receiver).to receive(:verified_signature?).and_return(false)
      expect(@receiver.perform!).to be false
    end

    context 'if signature is valid' do
      it 'calls recipient_user_ids' do
        expect(@receiver).to receive(:recipient_user_ids)
        @receiver.perform!
      end

      it 'saves the parsed object' do
        expect(@receiver).to receive(:save_object)
        @receiver.perform!
      end

      it 'enqueues a Workers::ReceiveLocalBatch' do
        expect(Workers::ReceiveLocalBatch).to receive(:perform_async).with(anything, anything, anything)
        @receiver.perform!
      end

      it 'intergrates' do
        inlined_jobs do
          @receiver.perform!
        end
      end
    end
  end

  describe '#verify_signature?' do
    it 'calls Slap#verified_for_key?' do
      receiver = Postzord::Receiver::Public.new(@xml)
      expect(receiver.salmon).to receive(:verified_for_key?).with(instance_of(OpenSSL::PKey::RSA))
      receiver.verified_signature?
    end
  end

  describe '#recipient_user_ids' do
    it 'calls User.all_sharing_with_person' do
      expect(User).to receive(:all_sharing_with_person).and_return(double(:pluck => []))
      receiver = Postzord::Receiver::Public.new(@xml)
      receiver.perform!
    end
  end

  describe '#receive_relayable' do
    before do
      @comment = bob.build_comment(:text => 'yo', :post => FactoryGirl.create(:status_message))
      @comment.save
      created_salmon = Salmon::Slap.create_by_user_and_activity(alice, @comment.to_diaspora_xml)
      xml = created_salmon.xml_for(nil)
      @comment.delete
      @receiver = Postzord::Receiver::Public.new(xml)
    end

    it 'receives only for the parent author if he is local to the pod' do
      comment = double.as_null_object
      @receiver.instance_variable_set(:@object, comment)

      expect(comment).to receive(:receive)
      @receiver.receive_relayable
    end

    it 'calls notifiy_users' do
      comment = double.as_null_object
      @receiver.instance_variable_set(:@object, comment)

      local_batch_receiver = double.as_null_object
      allow(Postzord::Receiver::LocalBatch).to receive(:new).and_return(local_batch_receiver)
      expect(local_batch_receiver).to receive(:notify_users)
      @receiver.receive_relayable
    end
  end
end
