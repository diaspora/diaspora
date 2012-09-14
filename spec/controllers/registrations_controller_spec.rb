#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe RegistrationsController do
  include Devise::TestHelpers

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @valid_params = {:user => {
      :username => "jdoe",
      :email    => "jdoe@example.com",
      :password => "password",
      :password_confirmation => "password"
      }
    }
    Webfinger.stub_chain(:new, :fetch).and_return(FactoryGirl.create(:person))
  end

  describe '#check_registrations_open!' do
    before do
      AppConfig[:registrations_closed] = true
    end

    after do
      AppConfig[:registrations_closed] = false
    end

    it 'redirects #new to the login page' do
      get :new
      flash[:error].should == I18n.t('registrations.closed')
      response.should redirect_to new_user_session_path
    end

    it 'redirects #create to the login page' do
      post :create, @valid_params
      flash[:error].should == I18n.t('registrations.closed')
      response.should redirect_to new_user_session_path
    end

    it 'does not redirect if there is a valid invite token' do
      i = InvitationCode.create(:user => bob)
      get :new, :invite => {:token => i.token}
      response.should_not be_redirect
    end

    it 'does redirect if there is an  invalid invite token' do
      get :new, :invite => {:token => 'fssdfsd'}
      response.should be_redirect
    end
  end



  describe "#create" do
    context "with valid parameters" do
      before do
        AppConfig[:registrations_closed] = false
      end

      before do
        user = FactoryGirl.build(:user)
        User.stub!(:build).and_return(user)
      end

      it "creates a user" do
        lambda {
          get :create, @valid_params
        }.should change(User, :count).by(1)
      end

      it "assigns @user" do
        get :create, @valid_params
        assigns(:user).should be_true
      end

      it "sets the flash" do
        get :create, @valid_params
        flash[:notice].should_not be_blank
      end

      it "redirects to the home path" do
        get :create, @valid_params
        response.should be_redirect
        response.location.should match /^#{root_url}\??$/
      end
    end

    context "with invalid parameters" do
      before do
        @invalid_params = @valid_params
        @invalid_params[:user][:password_confirmation] = "baddword"
      end

      it "does not create a user" do
        lambda { get :create, @invalid_params }.should_not change(User, :count)
      end

      it "does not create a person" do
        lambda { get :create, @invalid_params }.should_not change(Person, :count)
      end

      it "assigns @user" do
        get :create, @invalid_params
        assigns(:user).should_not be_nil
      end

      it "sets the flash error" do
        get :create, @invalid_params
        flash[:error].should_not be_blank
      end

      it "re-renders the form" do
        get :create, @invalid_params
        response.should render_template("registrations/new")
      end
    end
  end
end
