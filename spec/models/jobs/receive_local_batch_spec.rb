require 'spec_helper'
describe Job::ReceiveLocalBatch do
  #takes author id, post id and array of receiving user ids
  #for each recipient, it gets the aspects that the author is in
  #Gets all the aspect ids, and inserts into post_visibilities for each aspect
  #Then it sockets to those users
  #And notifies mentioned people
  before do
    @post = alice.build_post(:status_message, :text => 'Hey Bob')
    @post.save!
  end
  describe '.perform_delegate' do
    it 'calls .create_visibilities' do
      Job::ReceiveLocalBatch.should_receive(:create_visibilities).with(@post, [bob.id])
      Job::ReceiveLocalBatch.perform_delegate(@post.id, [bob.id])
    end
    it 'sockets to users' do
      Job::ReceiveLocalBatch.should_receive(:socket_to_users).with(@post, [bob.id])
      Job::ReceiveLocalBatch.perform_delegate(@post.id, [bob.id])
    end
    it 'notifies mentioned users' do
      Job::ReceiveLocalBatch.should_receive(:notify_mentioned_users).with(@post)
      Job::ReceiveLocalBatch.perform_delegate(@post.id, [bob.id])
    end
  end
  describe '.create_visibilities' do
    it 'creates a visibility for each user' do
      PostVisibility.exists?(:aspect_id => bob.aspects.first, :post_id => @post.id).should be_false
      Job::ReceiveLocalBatch.create_visibilities(@post, [bob.id])
      PostVisibility.exists?(:aspect_id => bob.aspects.first, :post_id => @post.id).should be_true
    end
  end
  describe '.socket_to_users' do
    before do
      @controller = mock()
      SocketsController.stub(:new).and_return(@controller)
    end
    it 'sockets to each user' do
      @controller.should_receive(:outgoing).with(bob.id, @post, {})
      Job::ReceiveLocalBatch.socket_to_users(@post, [bob.id])
    end
  end
  describe '.notify_mentioned_users' do
    it 'calls notify person for a mentioned person' do
      @post = alice.build_post(:status_message, :text => "Hey @{Bob; #{bob.diaspora_handle}}")
      @post.save!
      Notification.should_receive(:notify).with(bob, anything, alice.person)
      Job::ReceiveLocalBatch.notify_mentioned_users(@post)
    end
    it 'does not call notify person for a non-mentioned person' do
      Notification.should_not_receive(:notify)
      Job::ReceiveLocalBatch.notify_mentioned_users(@post)
    end
  end
end
