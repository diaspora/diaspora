require 'spec_helper'

describe Workers::ReceiveEncryptedSalmon do
  before do
    @user = alice
    @xml = '<xml></xml>'
    allow(User).to receive(:find){ |id|
      if id == @user.id
        @user
      else
        nil
      end
    }
  end
  it 'calls receive_salmon' do
    zord = double

    expect(zord).to receive(:perform!)
    expect(Postzord::Receiver::Private).to receive(:new).with(@user, hash_including(:salmon_xml => @xml)).and_return(zord)

    Workers::ReceiveEncryptedSalmon.new.perform(@user.id, @xml)
  end
end
