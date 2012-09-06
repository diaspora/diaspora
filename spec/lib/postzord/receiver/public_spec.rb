#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require Rails.root.join('lib', 'postzord')
require Rails.root.join('lib', 'postzord', 'receiver', 'public')

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
      receiver.salmon.should_not be_nil
    end
  end

  describe '#perform!' do
    before do
      @receiver = Postzord::Receiver::Public.new(@xml)
    end

    it 'calls verify_signature' do
      @receiver.should_receive(:verified_signature?)
      @receiver.perform!
    end

    it 'returns false if signature is not verified' do
      @receiver.should_receive(:verified_signature?).and_return(false)
      @receiver.perform!.should be_false
    end

    context 'if signature is valid' do
      it 'calls recipient_user_ids' do
        @receiver.should_receive(:recipient_user_ids)
        @receiver.perform!
      end

      it 'saves the parsed object' do
        @receiver.should_receive(:save_object)
        @receiver.perform!
      end

      it 'enqueues a Jobs::ReceiveLocalBatch' do 
        Resque.should_receive(:enqueue).with(Jobs::ReceiveLocalBatch, anything, anything, anything)
        @receiver.perform!
      end

      it 'intergrates' do
        fantasy_resque do
          @receiver.perform!
        end
      end
    end
  end

  describe '#verify_signature?' do
    it 'calls Slap#verified_for_key?' do
      receiver = Postzord::Receiver::Public.new(@xml)
      receiver.salmon.should_receive(:verified_for_key?).with(instance_of(OpenSSL::PKey::RSA))
      receiver.verified_signature?
    end
  end

  describe '#recipient_user_ids' do
    it 'calls User.all_sharing_with_person' do
      User.should_receive(:all_sharing_with_person).and_return(stub(:select => []))
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
      comment = stub.as_null_object
      @receiver.instance_variable_set(:@object, comment)

      comment.should_receive(:receive)
      @receiver.receive_relayable
    end

    it 'calls notifiy_users' do
      comment = stub.as_null_object
      @receiver.instance_variable_set(:@object, comment)

      local_batch_receiver = stub.as_null_object
      Postzord::Receiver::LocalBatch.stub(:new).and_return(local_batch_receiver)
      local_batch_receiver.should_receive(:notify_users)
      @receiver.receive_relayable
    end
  end
end
