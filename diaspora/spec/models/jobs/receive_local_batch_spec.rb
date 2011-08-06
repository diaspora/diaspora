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
  describe '.perform' do
    it 'calls .create_visibilities' do
      Job::ReceiveLocalBatch.should_receive(:create_visibilities).with(@post, [bob.id])
      Job::ReceiveLocalBatch.perform(@post.id, [bob.id])
    end
    it 'sockets to users' do
      Job::ReceiveLocalBatch.should_receive(:socket_to_users).with(@post, [bob.id])
      Job::ReceiveLocalBatch.perform(@post.id, [bob.id])
    end
    it 'notifies mentioned users' do
      Job::ReceiveLocalBatch.should_receive(:notify_mentioned_users).with(@post)
      Job::ReceiveLocalBatch.perform(@post.id, [bob.id])
    end
  end
  describe '.create_visibilities' do
    it 'creates a visibility for each user' do
      PostVisibility.exists?(:contact_id => bob.contact_for(alice.person).id, :post_id => @post.id).should be_false
      Job::ReceiveLocalBatch.create_visibilities(@post, [bob.id])
      PostVisibility.exists?(:contact_id => bob.contact_for(alice.person).id, :post_id => @post.id).should be_true
    end
    it 'does not raise if a visibility already exists' do
      PostVisibility.create!(:contact_id => bob.contact_for(alice.person).id, :post_id => @post.id)
      lambda {
        Job::ReceiveLocalBatch.create_visibilities(@post, [bob.id])
      }.should_not raise_error
    end
  end
  describe '.socket_to_users' do
    before do
      @controller = mock()
      SocketsController.stub(:new).and_return(@controller)
    end
    it 'sockets to each user' do
      @controller.should_receive(:outgoing).with(bob.id, @post, instance_of(Hash))
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
