require 'spec_helper' 
require File.join(Rails.root, 'lib','postzord', 'receiver', 'local_post_batch')

describe Postzord::Receiver::LocalPostBatch do
  before do
    @post = Factory(:status_message, :author => alice.person)
    @ids = [bob.id] 

    @receiver = Postzord::Receiver::LocalPostBatch.new(@post, @ids)
  end

  describe '.initialize' do
    it 'sets @post, @recipient_user_ids, and @user' do
      [:post, :recipient_user_ids, :users].each do |instance_var|
        @receiver.send(instance_var).should_not be_nil
      end
    end
  end

  describe '#perform!' do
    it 'calls .create_visibilities' do
      @receiver.should_receive(:create_visibilities)
      @receiver.perform!
    end

    it 'sockets to users' do
      @receiver.should_receive(:socket_to_users)
      @receiver.perform!
    end

    it 'notifies mentioned users' do
      @receiver.should_receive(:notify_mentioned_users)
      @receiver.perform!
    end

    it 'notifies users' do
      @receiver.should_receive(:notify_users)
      @receiver.perform!
    end
  end

  describe '#create_visibilities' do
    it 'calls Postvisibility.batch_import' do
      PostVisibility.should_receive(:batch_import)
      @receiver.create_visibilities
    end
  end

  describe '#socket_to_users' do
    before do
      @controller = mock()
      SocketsController.stub(:new).and_return(@controller)
    end

    it 'sockets to each user' do
      @controller.should_receive(:outgoing).with(bob, @post, instance_of(Hash))
      @receiver.socket_to_users
    end
  end

  describe '#notify_mentioned_users' do
    it 'calls notify person for a mentioned person' do
      sm = Factory(:status_message,
                   :author => alice.person,
                   :text => "Hey @{Bob; #{bob.diaspora_handle}}")

      receiver = Postzord::Receiver::LocalPostBatch.new(sm, @ids)
      Notification.should_receive(:notify).with(bob, anything, alice.person)
      receiver.notify_mentioned_users
    end

    it 'does not call notify person for a non-mentioned person' do
      Notification.should_not_receive(:notify)
      @receiver.notify_mentioned_users
    end
  end

  describe '#notify_users' do
    it 'calls notify for posts with notification type' do
      reshare = Factory.create(:reshare)
      Notification.should_receive(:notify)
      receiver = Postzord::Receiver::LocalPostBatch.new(reshare, @ids)
      receiver.notify_users
    end

    it 'calls notify for posts with notification type' do
      sm = Factory.create(:status_message, :author => alice.person)
      receiver = Postzord::Receiver::LocalPostBatch.new(sm, @ids)
      Notification.should_not_receive(:notify)
      receiver.notify_users
    end
  end
end
