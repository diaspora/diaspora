#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe RegistrationsController, :type => :controller do
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
    allow(Webfinger).to receive_message_chain(:new, :fetch).and_return(FactoryGirl.create(:person))
  end

  describe '#check_registrations_open!' do
    before do
      AppConfig.settings.enable_registrations = false
    end

    it 'redirects #new to the login page' do
      get :new
      expect(flash[:error]).to eq(I18n.t('registrations.closed'))
      expect(response).to redirect_to new_user_session_path
    end

    it 'redirects #create to the login page' do
      post :create, @valid_params
      expect(flash[:error]).to eq(I18n.t('registrations.closed'))
      expect(response).to redirect_to new_user_session_path
    end

    it 'does not redirect if there is a valid invite token' do
      i = InvitationCode.create(:user => bob)
      get :new, :invite => {:token => i.token}
      expect(response).not_to be_redirect
    end

    it 'does redirect if there is an  invalid invite token' do
      get :new, :invite => {:token => 'fssdfsd'}
      expect(response).to be_redirect
    end
  end

  describe "#create" do
    render_views

    context "with valid parameters" do
      before do
        AppConfig.settings.enable_registrations = true
        user = FactoryGirl.build(:user)
        allow(User).to receive(:build).and_return(user)
      end

      it "creates a user" do
        expect {
          get :create, @valid_params
        }.to change(User, :count).by(1)
      end

      it "assigns @user" do
        get :create, @valid_params
        expect(assigns(:user)).to be_truthy
      end

      it "sets the flash" do
        get :create, @valid_params
        expect(flash[:notice]).not_to be_blank
      end

      it "redirects to the home path" do
        get :create, @valid_params
        expect(response).to be_redirect
        expect(response.location).to match /^#{stream_url}\??$/
      end
    end

    context "with invalid parameters" do
      before do
        @invalid_params = @valid_params
        @invalid_params[:user][:password_confirmation] = "baddword"
      end

      it "does not create a user" do
        expect { get :create, @invalid_params }.not_to change(User, :count)
      end

      it "does not create a person" do
        expect { get :create, @invalid_params }.not_to change(Person, :count)
      end

      it "assigns @user" do
        get :create, @invalid_params
        expect(assigns(:user)).not_to be_nil
      end

      it "sets the flash error" do
        get :create, @invalid_params
        expect(flash[:error]).not_to be_blank
      end

      it "renders new" do
        get :create, @invalid_params
        expect(response).to render_template("registrations/new")
      end

      it "keeps invalid params in form" do
        get :create, @invalid_params
        expect(response.body).to match /jdoe@example.com/m
      end
    end
  end
end
