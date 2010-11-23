#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'making sure the spec runner works' do
  it 'should factory create a user with a person saved' do
    user = make_user
    loaded_user = User.first(:id => user.id)
    loaded_user.person.owner_id.should == user.id
  end

  describe 'fixtures' do
    it 'does not save the fixtures without prompting' do
      User.count.should == 0
    end

    it 'returns a user on fixed_user' do
      new_user = make_user
      new_user.is_a?(User).should be_true
      User.count.should == 1
    end

    it 'returns a different user on the second fixed_user' do
      new_user = make_user
      second_user = make_user

      User.count.should == 2
      new_user.id.should_not == second_user.id
    end
    
  end

  describe 'factories' do
    describe 'build' do
      it 'does not save a built user' do
        Factory.build(:user).persisted?.should be_false
      end
      
      it 'does not save a built person' do
        Factory.build(:person).persisted?.should be_false
      end
    end
  end

   describe '#connect_users' do
    before do
      @user1 = make_user
      @aspect1 = @user1.aspects.create(:name => "losers")
      @user2 = make_user
      @aspect2 = @user2.aspects.create(:name => "bruisers")
      connect_users(@user1, @aspect1, @user2, @aspect2)
    end

    it 'connects the first user to the second' do
      contact = @user1.contact_for @user2.person
      contact.should_not be_nil
      @user1.contacts.include?(contact).should be_true
      @aspect1.contacts.include?(contact).should be_true
      contact.aspects.include?( @aspect1 ).should be true
    end

    it 'connects the second user to the first' do
      contact = @user2.contact_for @user1.person
      contact.should_not be_nil
      @user2.contacts.include?(contact).should be_true
      @aspect2.contacts.include?(contact).should be_true
      contact.aspects.include?( @aspect2 ).should be true
    end

    it 'allows posting after running' do
      message = @user1.post(:status_message, :message => "Connection!", :to => @aspect1.id)
      @user2.reload.visible_posts.should include message
    end
  end
end
