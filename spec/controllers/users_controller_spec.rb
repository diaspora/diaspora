#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe UsersController do
  render_views

  let(:user)    { make_user }
  let!(:aspect) { user.aspects.create(:name => "lame-os") }

  let!(:old_password) { user.encrypted_password }
  let!(:old_language) { user.language }

  before do
    sign_in :user, user
  end

  describe '#export' do
    it 'returns an xml file'  do
      get :export
      response.header["Content-Type"].should include "application/xml"
    end
  end

  describe '#update' do
    it "doesn't overwrite random attributes" do
      params  = { :id => user.id,
                  :user => { :diaspora_handle => "notreal@stuff.com" } }
      lambda {
        put :update, params
      }.should_not change(user, :diaspora_handle)
    end

    context 'password updates' do
      it 'allows a user to change his password' do
        put(:update, :id => user.id, :user =>
            { :password => "foobaz",
              :password_confirmation => "foobaz" }
           )
        user.reload
        user.encrypted_password.should_not == old_password
      end

      it 'requires a matching password confirmation' do
        put(:update, :id => user.id, :user =>
            { :password => "foobarz",
              :password_confirmation => "not_the_same"}
           )
        user.reload
        user.encrypted_password.should == old_password
      end

      it 'does not update if the password fields are left blank' do
        put(:update, :id => user.id, :user =>
            { :password => "",
              :password_confirmation => ""}
           )
        user.reload
        user.encrypted_password.should == old_password
      end
    end

    describe 'language' do
      it 'allow the user to change his language' do
        old_language = 'en'
        user.language = old_language
        user.save
        put(:update, :id => user.id, :user =>
            { :language => "fr"}
           )
        user.reload
        user.language.should_not == old_language
      end
    end
  end

  describe '#edit' do
    it "returns a 200" do
      get 'edit', :id => user.id
      response.status.should == 200
    end
  end
end
