require 'spec_helper'

describe Postzord::Receiver::LocalBatch do
  before do
    @object = FactoryGirl.create(:status_message, :author => alice.person)
    @ids = [bob.id.to_s]
  end

  let(:receiver) { Postzord::Receiver::LocalBatch.new(@object, @ids) }

  describe '.initialize' do
    it 'sets @post, @recipient_user_ids, and @user' do
      [:object, :recipient_user_ids, :users].each do |instance_var|
        expect(receiver.send(instance_var)).not_to be_nil
      end
    end
  end

  describe '#receive!' do
    it 'calls .create_share_visibilities' do
      expect(receiver).to receive(:create_share_visibilities)
      receiver.receive!
    end
  end

  describe '#create_share_visibilities' do
    it 'calls sharevisibility.batch_import with hashes' do
      expect(ShareVisibility).to receive(:batch_import).with(@ids, @object)
      receiver.create_share_visibilities
    end
  end

  context 'integrates with a comment' do
    before do
      sm = FactoryGirl.create(:status_message, :author => alice.person)
      @object = FactoryGirl.create(:comment, :author => bob.person, :post => sm)
    end

    it 'does not call create_visibilities and notify_mentioned_users' do
      expect(receiver).not_to receive(:create_share_visibilities)
      receiver.perform!
    end
  end
end
