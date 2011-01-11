require 'spec_helper'

describe Jobs::ReceiveLocal do
  before do
    @user1 = make_user
    @user2 = make_user
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
    m = mock()
    m.should_receive(:receive_object)
    Postzord::Receiver.should_receive(:new).and_return(m)
    Jobs::ReceiveLocal.perform(@user1.id, @user2.person.id, @status_type, @status.id)
  end
end
