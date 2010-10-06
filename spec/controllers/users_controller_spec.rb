#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe UsersController do
  before do
    @user = Factory.create(:user)
    sign_in :user, @user
    @user.aspect(:name => "lame-os")
  end

  describe '#update' do
    context 'with a profile photo set' do
      before do
        @user.person.profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
        @user.person.profile.save
      end

      it "doesn't overwrite the profile photo when an empty string is passed in" do
        image_url = @user.person.profile.image_url
        put("update", :id => @user.id, "user"=> {"profile"=> 
          {"image_url"   => "",
            "last_name"  => @user.person.profile.last_name,
            "first_name" => @user.person.profile.first_name}})
        
        @user.person.profile.image_url.should == image_url
      end
    end

    context 'should allow the user to update their password' do
      it 'should change a users password ' do
        old_password = @user.encrypted_password

        put("update", :id => @user.id, "user"=> {"password" => "foobaz", 'password_confirmation' => "foobaz","profile"=> 
            {"image_url"   => "",
            "last_name"  => @user.person.profile.last_name,
            "first_name" => @user.person.profile.first_name}}) 

        @user.reload
        @user.encrypted_password.should_not == old_password
      end

      it 'should not change a password if they do not match' do 
        old_password = @user.encrypted_password 
        put("update", :id => @user.id, "user"=> {"password" => "foobarz", 'password_confirmation' => "not_the_same","profile"=> 
            {"image_url"   => "",
            "last_name"  => @user.person.profile.last_name,
            "first_name" => @user.person.profile.first_name}}) 
          @user.reload
          @user.encrypted_password.should == old_password
      end
  

      it 'should not update if the password fields are left blank' do 
        
          old_password = @user.encrypted_password 
          put("update", :id => @user.id, "user"=> {"password" => "", 'password_confirmation' => "","profile"=> 
              {"image_url"   => "",
              "last_name"  => @user.person.profile.last_name,
              "first_name" => @user.person.profile.first_name}}) 
            @user.reload
            @user.encrypted_password.should == old_password
      end
    end
  end
end
