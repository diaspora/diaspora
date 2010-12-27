#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe RegistrationsController do
  include Devise::TestHelpers

  render_views

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @valid_params = {:user => {
      :username => "jdoe",
      :email    => "jdoe@example.com",
      :password => "password",
      :password_confirmation => "password"
      }
    }
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
  end

  describe "#create" do
    context "with valid parameters" do
      before do
        user = Factory.build(:user)
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
        flash[:notice].should_not be_empty
      end
      it "redirects to the root path" do
        get :create, @valid_params
        response.should redirect_to root_path
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
