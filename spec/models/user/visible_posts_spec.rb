require File.dirname(__FILE__) + '/../../spec_helper'

describe User do
   before do
      @user = Factory.create(:user)
      @group = @user.group(:name => 'heroes')
      @group2 = @user.group(:name => 'losers')

      @user2 = Factory.create :user
      @user2_group = @user2.group(:name => 'dudes')

      friend_users(@user, @group, @user2, @user2_group)

      @user3 = Factory.create :user
      @user3_group = @user3.group(:name => 'dudes')
      friend_users(@user, @group2, @user3, @user3_group)
      
      @user4 = Factory.create :user
      @user4_group = @user4.group(:name => 'dudes')
      friend_users(@user, @group2, @user4, @user4_group)
   end

    it 'should generate a valid stream for a group of people' do
      status_message1 = @user2.post :status_message, :message => "hi"
      status_message2 = @user3.post :status_message, :message => "heyyyy"
      status_message3 = @user4.post :status_message, :message => "yooo"

      @user.receive status_message1.to_diaspora_xml
      @user.receive status_message2.to_diaspora_xml
      @user.receive status_message3.to_diaspora_xml
      @user.reload

      @user.visible_posts(:by_members_of => @group).include?(status_message1).should be true
      @user.visible_posts(:by_members_of => @group).include?(status_message2).should be false
      @user.visible_posts(:by_members_of => @group).include?(status_message3).should be false

      @user.visible_posts(:by_members_of => @group2).include?(status_message1).should be false
      @user.visible_posts(:by_members_of => @group2).include?(status_message2).should be true
      @user.visible_posts(:by_members_of => @group2).include?(status_message3).should be true
    end
end

