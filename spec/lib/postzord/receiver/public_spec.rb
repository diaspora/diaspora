#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/postzord')
require File.join(Rails.root, 'lib/postzord/receiver/public')

describe Postzord::Receiver::Public do
  before do
    @post = Factory.build(:status_message, :author => alice.person, :public => true)
    @created_salmon = Salmon::Slap.create_by_user_and_activity(alice, @post.to_diaspora_xml)
    @xml = @created_salmon.xml_for(nil)
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

    context 'if signature is valid' do
      it 'calls recipient_user_ids' do
        @receiver.should_receive(:recipient_user_ids)
        @receiver.perform!
      end

      it 'saves the parsed object' do
        @receiver.should_receive(:save_object)
        @receiver.perform!
      end

      it 'enqueues a Job::ReceiveLocalBatch' do 
        Resque.should_receive(:enqueue).with(Job::ReceiveLocalBatch, anything, anything)
        @receiver.perform!
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
end
