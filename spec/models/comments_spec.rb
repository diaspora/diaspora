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
      status = Factory.create(:status_message, :person => friend)
      @user.comment "sup dog", :on => status
      
      StatusMessage.first.comments.first.text.should == "sup dog"
      StatusMessage.first.comments.first.person.should == @user
    end
    it 'should not send out comments when we have no friends' do
      status = Factory.create(:status_message, :person => @user)
      Comment.send(:class_variable_get, :@@queue).should_not_receive(:add_post_request)
      @user.comment "sup dog", :on => status
    end
    describe 'comment propagation' do
      before do
        @friend = Factory.create(:friend)
        @friend_two = Factory.create(:friend)
        @friend_status = Factory.create(:status_message, :person => @friend)
        @user_status = Factory.create(:status_message, :person => @user)
      end
    
      it "should send a user's comment on a friend's post to that friend" do
        Comment.send(:class_variable_get, :@@queue).should_receive(:add_post_request)
        @user.comment "yo", :on => @friend_status
      end
    
      it 'should send a user comment on his own post to lots of friends' do
        allowed_urls = @user_status.friends_with_permissions.map!{|x| x = x.url + "receive/"}
        Comment.send(:class_variable_get, :@@queue).should_receive(:add_post_request).with(allowed_urls, anything )
        @user.comment "yo", :on => @user_status
      end
    
      it 'should send a comment a friend made on your post to all friends' do
        Comment.send(:class_variable_get, :@@queue).should_receive(:add_post_request)
        com = Comment.create(:person => @friend, :text => "balls", :post => @user_status)
      end
    
      it 'should not send a comment a friend made on a friend post to anyone' do
        Comment.send(:class_variable_get, :@@queue).should_not_receive(:add_post_request)
        com = Comment.create(:person => @friend, :text => "balls", :post => @friend_status)  
      end
      

    end
  end
end