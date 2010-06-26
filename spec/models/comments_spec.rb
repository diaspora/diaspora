require 'spec_helper'

describe Comment do
  describe "user" do
    before do
      @user = Factory.create :user
    end
    it "should be able to comment on his own status" do
      status = Factory.create(:status_message, :person => @user)
      status.comments.should == []

      @user.comment "Yeah, it was great", :on => status
      StatusMessage.first.comments.first.text.should == "Yeah, it was great"
    end

    it "should be able to comment on a friend's status" do
      friend = Factory.create :friend
      status = Factory.create(:status_message, :person => @friend)
      @user.comment "sup dog", :on => status
      
      StatusMessage.first.comments.first.text.should == "sup dog"
      StatusMessage.first.comments.first.person.should == @user
    end

  end
end