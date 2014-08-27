require 'spec_helper'

describe Workers::Receive do
  before do
    @user = alice
    @person = FactoryGirl.create(:person)
    @xml = '<xml></xml>'
    allow(User).to receive(:find){ |id|
      if id == @user.id
        @user
      else
        nil
      end
    }
  end

  it 'calls receive' do
    zord_double = double()
    expect(zord_double).to receive(:parse_and_receive).with(@xml)
    expect(Postzord::Receiver::Private).to receive(:new).with(@user, anything).and_return(zord_double)
    Workers::Receive.new.perform(@user.id, @xml, @person.id)
  end
end
