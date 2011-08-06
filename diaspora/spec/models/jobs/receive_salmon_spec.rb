require 'spec_helper'

describe Job::ReceiveSalmon do
  before do
    @user = alice
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
    Job::ReceiveSalmon.perform(@user.id, @xml)
  end
end
