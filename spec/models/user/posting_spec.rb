require File.dirname(__FILE__) + '/../../spec_helper'

describe User do
   before do
     @user = Factory.create :user
     @group = @user.group(:name => 'heroes')
     @group1 = @user.group(:name => 'heroes')

     @user2 = Factory.create(:user)
     @group2 = @user2.group(:name => 'losers') 

     @user3 = Factory.create(:user)
     @group3 = @user3.group(:name => 'heroes')

     @user4 = Factory.create(:user)
     @group4 = @user4.group(:name => 'heroes')

     friend_users(@user, @group, @user2, @group2)
     friend_users(@user, @group, @user3, @group3)
     friend_users(@user, @group1, @user4, @group4)
   end

  it 'should not be able to post without a group' do
    proc {@user.post(:status_message, :message => "heyheyhey")}.should raise_error /You must post to someone/ 
  end

  describe 'dispatching' do
    before do
      @post = @user.build_post :status_message, :message => "hey"
    end
    it 'should push a post to a group' do
      @user.should_receive(:salmon).twice
      @user.push_to_groups(@post, @group.id)
    end

    it 'should push a post to all groups' do
      @user.should_receive(:salmon).exactly(3).times
      @user.push_to_groups(@post, :all)
    end

    it 'should push to people' do
      @user.should_receive(:salmon).twice
      @user.push_to_people(@post, [@user2.person, @user3.person])
    end
    
    
  end
end
