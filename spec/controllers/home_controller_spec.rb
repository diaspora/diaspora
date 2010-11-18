#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe HomeController do
  render_views

  before do
    @user = make_user
    sign_in @user
    sign_out @user
  end

  describe '#show' do
    it 'should show a login link if no user is not logged in' do
      get :show 
      response.body.should include("log in")
    end

    it 'should redirect to aspects index if user is logged in' do
      sign_in @user
      get :show 
      response.should redirect_to aspects_path
    end

  end
end
