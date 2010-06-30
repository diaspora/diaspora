require 'spec_helper'

describe Person do
  it 'should not allow two friends with the same url' do
    friend_one = Factory.create(:friend)
    friend_two = Factory.build(:friend, :url => friend_one.url)
    friend_two.valid?.should == false
  end
  
  it 'should not allow a friend with the same url as the user' do
    user = Factory.create(:user)
    friend = Factory.build(:friend, :url => user.url)
    friend.valid?.should == false

  end
end
