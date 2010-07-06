require 'spec_helper'

describe FriendRequest do 
  before do
    sender = Factory.build(:user, :email => "bob@aol.com", :url => "http://google.com/")
    recipient = Factory.build(:person, :email => "robert@grimm.com", :url => "http://robert.com")
    @r = FriendRequest.create(:sender => sender, :recipient => recipient)
  end
  
  it 'should have sender and recipient credentials after serialization' do
    xml = @r.to_xml.to_s
    xml.include?(@r.sender.url).should be true
    xml.include?(@r.sender.email).should be true
    xml.include?(@r.recipient.url).should be true
    xml.include?(@r.recipient.email).should be true
  end

  describe "acceptance" do
    it 'should create a friend' do
      Friend.count.should be 0
      @r.accept
      Friend.count.should be 1
    end

    it 'should remove the request' do
      FriendRequest.count.should be 1
      @r.accept
      FriendRequest.count.should be 0
    end
  end

  describe "rejection" do 
    it 'should not create a friend' do
      Friend.count.should be 0
      @r.reject
      Friend.count.should be 0
    end

    it 'should remove the request' do
      FriendRequest.count.should be 1
      @r.reject
      FriendRequest.count.should be 0
    end
  end
  
end
