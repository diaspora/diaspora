#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:user)   { Factory(:user) }

  describe "validations" do
    it "downcases the username" do
      user = Factory.build(:user, :username => "ALLUPPERCASE")
      user.valid?
      user.username.should == "alluppercase"
    end
  end

  describe '#diaspora_handle' do
    it 'uses the pod config url to set the diaspora_handle' do
      user.diaspora_handle.should == user.username + "@example.org"
    end
  end

  context 'profiles' do
    it 'should be able to update their profile and send it to their friends' do
      updated_profile = { :profile => {
                            :first_name => 'bob',
                            :last_name => 'billytown',
                            :image_url => "http://clown.com"} }

      user.update_profile(updated_profile).should be true
      user.profile.image_url.should == "http://clown.com"
    end
  end

  context 'aspects' do
    let(:aspect) { user.aspect(:name => 'heroes') }
    let(:user2)   { Factory(:user) }
    let(:aspect2) { user2.aspect(:name => 'stuff') }

    it 'should delete an empty aspect' do
      user.drop_aspect(aspect)
      user.aspects.include?(aspect).should == false
    end

    it 'should not delete an aspect with friends' do
      friend_users(user, Aspect.find_by_id(aspect.id), user2, Aspect.find_by_id(aspect2.id))
      aspect.reload
      proc{user.drop_aspect(aspect)}.should raise_error /Aspect not empty/
      user.aspects.include?(aspect).should == true
    end
  end

end
