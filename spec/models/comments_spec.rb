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


    it 'should be able to send a post owner any new comments a user adds' do
      friend = Factory.create(:friend)
      status = Factory.create(:status_message, :person => friend)
      
      Comment.send(:class_variable_get, :@@queue).should_receive(:add_post_request)
      @user.comment "yo", :on => status
    end

  end
end
