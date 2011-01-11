require 'spec_helper'

describe Jobs::ReceiveSalmon do
  before do
    @user = make_user
    @user2 = make_user
    @xml = '<xml></xml>'
    User.stub(:find){ |id|
      if id == @user.id
        @user
      else
        nil
      end
    }
  end
  it 'calls receive_salmon' do
    salmon_mock = mock()

    salmon_mock.should_receive(:perform)
    Postzord::Receiver.should_receive(:new).and_return(salmon_mock)
    Jobs::ReceiveSalmon.perform(@user.id, @xml)
  end
end
