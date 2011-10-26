require 'spec_helper'
describe Jobs::ReceiveLocalBatch do
  #takes author id, post id and array of receiving user ids
  #for each recipient, it gets the aspects that the author is in
  #Gets all the aspect ids, and inserts into share_visibilities for each aspect
  #Then it sockets to those users
  #And notifies mentioned people
  before do
    @post = alice.build_post(:status_message, :text => 'Hey Bob')
    @post.save!
  end

  describe '.perform' do
    it 'calls Postzord::Receiver::LocalBatch' do
      pending
    end
  end
end
