require 'spec_helper'

describe FriendRequest do 
  before do
    sender = Factory.build(:user, :email => "bob@aol.com", :url => "http://google.com/")
    recipient = Factory.build(:person, :email => "robert@grimm.com", :url => "http://localhost:3000/")
    @request = FriendRequest.create(:sender => sender, :recipient => recipient)
  end
  
  it 'should have sender and recipient credentials after serialization' do
    xml = @request.to_xml.to_s
    xml.include?(@request.sender.url).should be true
    xml.include?(@request.sender.email).should be true
    xml.include?(@request.recipient.url).should be true
    xml.include?(@request.recipient.email).should be true
  end

  describe "acceptance" do
    it 'should create a friend' do
      Friend.count.should be 0
      @request.accept
      Friend.count.should be 1
    end

    it 'should remove the request' do
      FriendRequest.count.should be 1
      @request.accept
      FriendRequest.count.should be 0
    end
  end

  describe "rejection" do 
    it 'should not create a friend' do
      Friend.count.should be 0
      @request.reject
      Friend.count.should be 0
    end

    it 'should remove the request' do
      FriendRequest.count.should be 1
      @request.reject
      FriendRequest.count.should be 0
    end
  end

  it 'should dispatch upon creation' do
    FriendRequest.send(:class_variable_get, :@@queue).should_receive(:add_post_request)
    sender = Factory.build(:user, :email => "bob@aol.com", :url => "http://google.com/")
    recipient = Factory.build(:person, :email => "robert@grimm.com", :url => "http://localhost:3000/")
    FriendRequest.create(:sender => sender, :recipient => recipient)
  end 
end
