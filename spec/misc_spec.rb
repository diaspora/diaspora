#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'making sure the spec runner works' do

  it 'should not delete the database mid-spec' do
    User.count.should == 0
    Factory.create(:user)
    User.count.should == 1
  end

  it 'should make sure the last user no longer exsists' do
    User.count.should == 0
  end

  it 'should factory create a user with a person saved' do
    user = Factory.create(:user)
    loaded_user = User.first(:id => user.id)
    loaded_user.person.owner_id.should == user.id
  end
  describe 'testing a before do block' do
    before do
      Factory.create(:user)

    end

    it 'should have cleaned before the before do block runs' do
      User.count.should == 1
    end

  end
  describe '#friend_users' do
    before do
      @user1 = Factory.create(:user)
      @aspect1 = @user1.aspect(:name => "losers")
      @user2 = Factory.create(:user)
      @aspect2 = @user2.aspect(:name => "bruisers")
      friend_users(@user1, @aspect1, @user2, @aspect2)
      @user1.reload
      @aspect1.reload
      @user2.reload
      @aspect2.reload
    end
    
    it 'makes the first user friends with the second' do
      @aspect1.people.include?(@user2.person).should be_true
    end

    it 'makes the second user friends with the first' do
      @aspect2.people.include?(@user1.person).should be_true
    end
  end
end
