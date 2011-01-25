#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe UsersController do
  render_views

  before do
    @user = alice
    @aspect = @user.aspects.first
    sign_in :user, @user
  end

  describe '#export' do
    it 'returns an xml file'  do
      get :export
      response.header["Content-Type"].should include "application/xml"
    end
  end

  describe '#update' do
    it "doesn't overwrite random attributes" do
      params  = { :id => @user.id,
                  :user => { :diaspora_handle => "notreal@stuff.com" } }
      lambda {
        put :update, params
      }.should_not change(@user, :diaspora_handle)
    end

    context 'password updates' do
      before do
        @password_params = {:current_password => 'bluepin7',
                            :password => "foobaz",
                            :password_confirmation => "foobaz"}
      end

      it "uses devise's update with password" do
        @user.should_receive(:update_with_password).with(hash_including(@password_params))
        @controller.stub!(:current_user).and_return(@user)
        put :update, :id => @user.id, :user => @password_params
      end
    end

    describe 'language' do
      it 'allow the user to change his language' do
        old_language = 'en'
        @user.language = old_language
        @user.save
        put(:update, :id => @user.id, :user =>
            { :language => "fr"}
           )
        @user.reload
        @user.language.should_not == old_language
      end
    end
  end

  describe '#edit' do
    it "returns a 200" do
      get 'edit', :id => @user.id
      response.status.should == 200
    end
  end
end
