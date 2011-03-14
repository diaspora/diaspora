#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe UsersController do
  render_views

  before do
    @user = alice
    @aspect = @user.aspects.first
    @aspect1 = @user.aspects.create(:name => "super!!")
    sign_in :user, @user
  end

  describe '#export' do
    it 'returns an xml file'  do
      get :export
      response.header["Content-Type"].should include "application/xml"
    end
  end

  describe '#public' do
    it 'renders xml' do
      sm = Factory(:status_message, :public => true, :author => @user.person)
      get :public, :username => @user.username
      response.body.should include(sm.text)
    end
  end

  describe '#update' do
    before do
      @params  = { :id => @user.id,
                  :user => { :diaspora_handle => "notreal@stuff.com" } }

    end
    it "doesn't overwrite random attributes" do
      lambda {
        put :update, @params
      }.should_not change(@user, :diaspora_handle)
    end

    it 'redirects to the user edit page' do
      put :update, @params
      response.should redirect_to edit_user_path(@user)
    end

    it 'responds with a 204 on a js request' do
      put :update, @params.merge(:format => :js)
      response.status.should == 204
    end

    context "open aspects" do
      before do
        @index_params = {:id => @user.id, :user => {:a_ids => [@aspect.id.to_s, @aspect1.id.to_s]} }
      end

      it "stores the aspect params in the user" do
        put :update,  @index_params
        @user.reload.aspects.where(:open => true).all.to_set.should == [@aspect, @aspect1].to_set
      end

      it "correctly resets the home state" do
        @index_params[:user][:a_ids] = ["home"]

        put :update, @index_params
        @user.aspects.where(:open => true).should == []
      end
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

    describe 'email settings' do
      it 'lets the user turn off mail' do
        par = {:id => @user.id, :user => {:email_preferences => {'mentioned' => 'true'}}}
        proc{
          put :update, par
        }.should change(@user.user_preferences, :count).by(1)
      end

      it 'lets the user get mail again' do
        @user.user_preferences.create(:email_type => 'mentioned')
        par = {:id => @user.id, :user => {:email_preferences => {'mentioned' => 'false'}}}
        proc{
          put :update, par
        }.should change(@user.user_preferences, :count).by(-1)

      end
    end
  end

  describe '#edit' do
    it "returns a 200" do
      get 'edit', :id => @user.id
      response.status.should == 200
    end

    it 'set @email_pref to false when there is a user pref' do
      @user.user_preferences.create(:email_type => 'mentioned')
      get 'edit', :id => @user.id
      assigns[:email_prefs]['mentioned'].should be_false
    end
  end
end
