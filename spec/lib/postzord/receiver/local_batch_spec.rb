require 'spec_helper'
require File.join(Rails.root, 'lib','postzord', 'receiver', 'local_batch')

describe Postzord::Receiver::LocalBatch do
  before do
    @object = Factory(:status_message, :author => alice.person)
    @ids = [bob.id.to_s]
  end

  let(:receiver) { Postzord::Receiver::LocalBatch.new(@object, @ids) }

  describe '.initialize' do
    it 'sets @post, @recipient_user_ids, and @user' do
      [:object, :recipient_user_ids, :users].each do |instance_var|
        receiver.send(instance_var).should_not be_nil
      end
    end
  end

  describe '#receive!' do
    it 'calls .create_share_visibilities' do
      receiver.should_receive(:create_share_visibilities)
      receiver.receive!
    end

    it 'notifies mentioned users' do
      receiver.should_receive(:notify_mentioned_users)
      receiver.receive!
    end

    it 'notifies users' do
      receiver.should_receive(:notify_users)
      receiver.receive!
    end
  end

  describe '#create_share_visibilities' do
    it 'calls sharevisibility.batch_import with hashes' do
      ShareVisibility.should_receive(:batch_import).with(instance_of(Array), @object)
      receiver.create_share_visibilities
    end
  end

  describe '#notify_mentioned_users' do
    it 'calls notify person for a mentioned person' do
      sm = Factory(:status_message,
                   :author => alice.person,
                   :text => "Hey @{Bob; #{bob.diaspora_handle}}")

      receiver2 = Postzord::Receiver::LocalBatch.new(sm, @ids)
      Notification.should_receive(:notify).with(bob, anything, alice.person)
      receiver2.notify_mentioned_users
    end

    it 'does not call notify person for a non-mentioned person' do
      Notification.should_not_receive(:notify)
      receiver.notify_mentioned_users
    end
  end

  describe '#notify_users' do
    it 'calls notify for posts with notification type' do
      reshare = Factory.create(:reshare)
      Notification.should_receive(:notify)
      receiver = Postzord::Receiver::LocalBatch.new(reshare, @ids)
      receiver.notify_users
    end

    it 'calls notify for posts with notification type' do
      sm = Factory.create(:status_message, :author => alice.person)
      receiver = Postzord::Receiver::LocalBatch.new(sm, @ids)
      Notification.should_not_receive(:notify)
      receiver.notify_users
    end
  end

  context 'integrates with a comment' do
    before do
      sm = Factory(:status_message, :author => alice.person)
      @object = Factory(:comment, :author => bob.person, :post => sm)
    end

    it 'calls notify_users' do
      receiver.should_receive(:notify_users)
      receiver.perform!
    end

    it 'does not call create_visibilities and notify_mentioned_users' do
      receiver.should_not_receive(:notify_mentioned_users)
      receiver.should_not_receive(:create_share_visibilities)
      receiver.perform!
    end
  end

  describe '#update_cache!' do
    before do

    end

    it 'adds to a redis cache for users sharing with author' do
      users = [bob]
      @zord = Postzord::Receiver::LocalBatch.new(@object, users.map{|u| u.id})

      sort_order = "created_at"

      cache = mock
      RedisCache.should_receive(:new).exactly(users.length).times.with(instance_of(User), sort_order).and_return(cache)

      cache.should_receive(:add).exactly(users.length).times.with(@object.created_at.to_i, @object.id)

      @zord.update_cache!
    end

    it 'does not add to the redis cache of the users not contact with author' do
      users = [bob, eve]
      @zord = Postzord::Receiver::LocalBatch.new(@object, users.map{|u| u.id})

      RedisCache.should_receive(:new).once.with(bob, anything()).and_return(stub.as_null_object)

      @zord.update_cache!
    end

    it 'does not add to the redis cache of users not sharing with the author' do
      alice.share_with(eve.person, alice.aspects.first)
      users = [bob, eve]
      @zord = Postzord::Receiver::LocalBatch.new(@object, users.map{|u| u.id})

      RedisCache.should_receive(:new).once.with(bob, anything()).and_return(stub.as_null_object)

      @zord.update_cache!
    end
  end
end
