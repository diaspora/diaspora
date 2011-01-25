#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ServicesController do
  render_views
  let(:mock_access_token) { Object.new }

  let(:omniauth_auth) {
    { 'provider' => 'twitter',
      'uid'      => '2',
      'user_info'   => { 'nickname' => 'grimmin' },
      'credentials' => { 'token' => 'tokin', 'secret' =>"not_so_much" }
      }
  }

  before do
    @user   = alice
    @aspect = @user.aspects.first

    sign_in :user, @user
    @controller.stub!(:current_user).and_return(@user)
    mock_access_token.stub!(:token => "12345", :secret => "56789")
  end

  describe '#index' do
    it 'displays all connected serivices for a user' do
      4.times do
        @user.services << Factory(:service)
      end

      get :index
      assigns[:services].should == @user.services
    end
  end

  describe '#create' do
    it 'creates a new OmniauthService' do
      request.env['omniauth.auth'] = omniauth_auth
      lambda{
        post :create
      }.should change(@user.services, :count).by(1)
    end

    it 'redirects to getting started if the user is getting started' do
      @user.getting_started = true
      request.env['omniauth.auth'] = omniauth_auth
      post :create
      response.should redirect_to getting_started_path(:step => 3)
    end

    it 'redirects to services url' do
      @user.getting_started = false
      request.env['omniauth.auth'] = omniauth_auth
      post :create
      response.should redirect_to services_url
    end


    it 'creates a twitter service' do
      Service.delete_all
      @user.getting_started = false
      request.env['omniauth.auth'] = omniauth_auth
      post :create
      @user.reload.services.first.class.name.should == "Services::Twitter"
    end
  end

  describe '#destroy' do
    before do
      @service1 = Factory.create(:service)
      @user.services << @service1
    end
    it 'destroys a service selected by id' do
      lambda{
        delete :destroy, :id => @service1.id
      }.should change(@user.services, :count).by(-1)
    end
  end

  describe '#finder' do
    before do
      @service1 = Factory.create(:service, :provider => 'facebook')
      @user.services << @service1
    end

    it 'calls the finder method for the service for that user' do
      @user.services.stub!(:where).and_return([@service1])
      @service1.should_receive(:finder).and_return({})
      get :finder, :provider => @service1.provider
    end
  end
end
