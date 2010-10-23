#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'making sure the spec runner works' do
  it 'should factory create a user with a person saved' do
    user = Factory.create(:user)
    loaded_user = User.first(:id => user.id)
    loaded_user.person.owner_id.should == user.id
  end

   describe '#friend_users' do
    before do
      @user1 = Factory.create(:user)
      @aspect1 = @user1.aspect(:name => "losers")
      @user2 = Factory.create(:user)
      @aspect2 = @user2.aspect(:name => "bruisers")
      friend_users(@user1, @aspect1, @user2, @aspect2)
    end

    it 'makes the first user friends with the second' do
      contact = @user1.contact_for @user2.person
      @user1.friends.include?(contact).should be_true
      @aspect1.people.include?(contact).should be_true
      contact.aspects.include?( @aspect1 ).should be true
    end

    it 'makes the second user friends with the first' do
      contact = @user2.contact_for @user1.person
      @user2.friends.include?(contact).should be_true
      @aspect2.people.include?(contact).should be_true
      contact.aspects.include?( @aspect2 ).should be true
    end
  end
end
