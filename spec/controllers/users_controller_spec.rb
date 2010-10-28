#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe UsersController do

  let(:user) { Factory(:user) }
  let!(:aspect) { user.aspect(:name => "lame-os") }

  let!(:old_password) { user.encrypted_password }
  let!(:old_language) { user.language }
    
  before do
    sign_in :user, user
  end

  describe '#export' do
    it 'should return an xml file'  do
      get :export
      response.header["Content-Type"].should include "application/xml"
    end
  end

  describe '#update' do
    it "doesn't overwrite random attributes" do
      params  = {:diaspora_handle => "notreal@stuff.com"}
      proc{ put 'update', :id => user.id, "user" => params }.should_not change(user, :diaspora_handle)
    end

    context 'should allow the user to update their password' do
      it 'should change a users password ' do
        put("update", :id => user.id, "user"=> {"password" => "foobaz", 'password_confirmation' => "foobaz"})
        user.reload
        user.encrypted_password.should_not == old_password
      end

      it 'should not change a password if they do not match' do
        put("update", :id => user.id, "user"=> {"password" => "foobarz", 'password_confirmation' => "not_the_same"})
        user.reload
        user.encrypted_password.should == old_password
      end

      it 'should not update if the password fields are left blank' do
        put("update", :id => user.id, "user"=> {"password" => "", 'password_confirmation' => ""})
        user.reload
        user.encrypted_password.should == old_password
      end
    end

    describe 'language' do
      it 'should allow user to change his language' do
        put("update", :id => user.id, "user" => {"language" => "fr"})
        user.reload
        user.language.should_not == old_language
      end
    end
  end
end
