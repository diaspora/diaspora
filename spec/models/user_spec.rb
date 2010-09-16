#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require File.dirname(__FILE__) + '/../spec_helper'

describe User do
   before do
      @user = Factory.create(:user)
      @aspect = @user.aspect(:name => 'heroes')
   end

  describe 'profiles' do
    it 'should be able to update their profile and send it to their friends' do
      Factory.create(:person)

      updated_profile = {:profile => {:first_name => 'bob', :last_name => 'billytown', :image_url => "http://clown.com"}}

      @user.update_profile(updated_profile).should == true
      @user.profile.image_url.should == "http://clown.com"
    end
  end

  describe 'aspects' do
    it 'should delete an empty aspect' do
      @user.aspects.include?(@aspect).should == true
      @user.drop_aspect(@aspect)
      @user.reload

      @user.aspects.include?(@aspect).should == false
    end

    it 'should not delete an aspect with friends' do
      user2   = Factory.create(:user)
      aspect2 = user2.aspect(:name => 'stuff')
      user2.reload
      aspect2.reload

      friend_users(@user, Aspect.find_by_id(@aspect.id), user2, Aspect.find_by_id(aspect2.id))
      @aspect.reload
      
      @user.aspects.include?(@aspect).should == true

      proc{@user.drop_aspect(@aspect)}.should raise_error /Aspect not empty/

      @user.reload
      @user.aspects.include?(@aspect).should == true
    end
  end
end
