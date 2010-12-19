require 'spec_helper'

describe Jobs::ReceiveLocal do
  before do
    @user1 = Factory.create(:user)
    @user2 = Factory.create(:user)
    @status = Factory(:status_message)
    @status_type = @status.class.to_s

    User.stub(:find){ |id|
      if id == @user1.id
        @user1
      else
        nil
      end
    }

    Person.stub(:find){ |id|
      if id == @user2.person.id
        @user2.person
      else
        nil
      end
    }

    StatusMessage.stub(:find){ |id|
      if id == @status.id
        @status
      else
        nil
      end
    }
  end

  it 'calls receive_object' do
    @user1.should_receive(:receive_object).with(@status, @user2.person).and_return(true)
    Jobs::ReceiveLocal.perform(@user1.id, @user2.person.id, @status_type, @status.id)
  end
end
