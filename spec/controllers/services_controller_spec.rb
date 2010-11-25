#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ServicesController do
  render_views
  let(:user)      { make_user }
  let!(:aspect)   { user.aspects.create(:name => "lame-os") }

  let!(:service1) {a = Factory(:service); user.services << a; a}
  let!(:service2) {a = Factory(:service); user.services << a; a}
  let!(:service3) {a = Factory(:service); user.services << a; a}
  let!(:service4) {a = Factory(:service); user.services << a; a}

  let(:mock_access_token) { Object.new }

  let(:omniauth_auth) {{ 'provider' => 'twitter', 'uid' => '2',
                         'user_info' => { 'nickname' => 'grimmin' },
                         'extra' => { 'access_token' => mock_access_token }}}

  before do
    sign_in :user, user
    @controller.stub!(:current_user) { user }
    mock_access_token.stub!(:token => "12345", :secret => "56789")
  end

  describe '#index' do
    it 'displays all connected serivices for a user' do
      get :index
      assigns[:services].should == user.services
    end
  end

  describe '#create' do
    it 'creates a new OmniauthService' do
      request.env['omniauth.auth'] = omniauth_auth
      expect { post :create }.to change(user.services, :count).by(1)
    end

    it 'redirects to getting started if the user still getting started' do
      user.getting_started = true
      request.env['omniauth.auth'] = omniauth_auth
      post :create
      response.should redirect_to(getting_started_path(:step => 3))
    end

    it 'redirects to services url' do
      user.getting_started = false
      request.env['omniauth.auth'] = omniauth_auth
      post :create
      response.should redirect_to(services_url)
    end
  end

  describe '#destroy' do
    it 'destroys a service of a users with the id' do
      expect { delete :destroy, :id => service1.id.to_s }.to change(user.services, :count).by(-1)
    end
  end
end
