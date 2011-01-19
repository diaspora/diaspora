require 'spec_helper'

describe Job::ReceiveLocal do
  before do
    @user1 = alice
    @person1 = @user1.person
    @user2 = eve
    @person2 = @user2.person
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
      if id == @person2.id
        @person2
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
    Job::ReceiveLocal.perform(@user1.id, @person2.id, @status_type, @status.id)
  end
end
