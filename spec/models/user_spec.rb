#   Copyright (c) 2010, Disapora Inc.  This file is
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
end
