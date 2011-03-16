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
    end
    it 'sockets to users' do
    end
    it 'notifies mentioned users' do
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
    
  end
end
