require 'spec_helper'

describe Person do
  it 'should not allow a friend with the same url as the user' do
    user = Factory.create(:user)
    friend = Factory.build(:friend, :url => user.url)
    friend.valid?.should == false

  end
end
