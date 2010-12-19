require 'spec_helper'

describe Jobs::Receive do
  before do
    @user = Factory.create(:user)
    @person = Factory(:person)
    @xml = '<xml></xml>'
    User.stub(:find){ |id|
      if id == @user.id
        @user
      else
        nil
      end
    }
  end
  it 'calls receive' do
    @user.should_receive(:receive).with(@xml, @person).once
    Jobs::Receive.perform(@user.id, @xml, @person.id)
  end
end
