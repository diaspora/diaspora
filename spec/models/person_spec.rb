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

  it 'should serialize to xml' do
    friend_one = Factory.create(:friend)
    xml = friend_one.to_xml.to_s
    (xml.include? "friend").should == true
  end
  it 'should have a profile in its xml' do
    user = Factory.create(:user)
    xml = user.to_xml.to_s
    (xml.include? "first_name").should == true
  end
end
