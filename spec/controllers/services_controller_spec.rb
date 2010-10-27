#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ServicesController do
  render_views
  let(:user) { Factory(:user) }
  let!(:aspect) { user.aspect(:name => "lame-os") }

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
    mock_access_token.stub!(:token).and_return("12345")
    mock_access_token.stub!(:secret).and_return("56789")
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
      lambda{post :create}.should change(user.services, :count).by(1)
    end
  end

  describe '#destroy' do
    it 'should destroy a service of a users with the id' do
      lambda{delete :destroy, :id => service1.id.to_s}.should change(user.services, :count).by(-1)
    end
  end
end
