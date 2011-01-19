#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'making sure the spec runner works' do
  it 'factoy creates a user with a person saved' do
    user = Factory.create(:user)
    loaded_user = User.find(user.id)
    loaded_user.person.owner_id.should == user.id
  end

  describe 'factories' do
    describe 'build' do
      it 'does not save a built user' do
        Factory.build(:user).should_not be_persisted
      end

      it 'does not save a built person' do
        Factory.build(:person).should_not be_persisted
      end
    end
  end

   describe '#connect_users' do
    before do
      @user1 = Factory.create(:user)
      @aspect1 = @user1.aspects.create(:name => "losers")
      @user2 = Factory.create(:user)
      @aspect2 = @user2.aspects.create(:name => "bruisers")
      connect_users(@user1, @aspect1, @user2, @aspect2)
    end

    it 'connects the first user to the second' do
      contact = @user1.contact_for @user2.person
      contact.should_not be_nil
      @user1.contacts.reload.include?(contact).should be_true
      @aspect1.contacts.include?(contact).should be_true
      contact.aspects.include?(@aspect1).should be_true
    end

    it 'connects the second user to the first' do
      contact = @user2.contact_for @user1.person
      contact.should_not be_nil
      @user2.contacts.reload.include?(contact).should be_true
      @aspect2.contacts.include?(contact).should be_true
      contact.aspects.include?(@aspect2).should be_true
    end

    it 'allows posting after running' do
      message = @user1.post(:status_message, :message => "Connection!", :to => @aspect1.id)
      @user2.reload.visible_posts.should include message
    end
  end
end
