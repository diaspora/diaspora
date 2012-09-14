#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe HomeController do
  describe '#show' do
    it 'does not redirect' do
      sign_out :user
      get :show
      response.should_not be_redirect
    end

    context 'redirection' do
      before do
        sign_in alice
      end

      it 'points to the stream if a user has contacts' do
        get :show, :home => true
        response.should redirect_to(stream_path)
      end
    end
  end

  describe '#toggle_mobile' do
    it 'changes :mobile to :html' do
      session[:mobile_view] = true
      get :toggle_mobile
      session[:mobile_view].should be_false
    end

    it 'changes :html to :mobile' do
      session[:mobile_view] = nil
      get :toggle_mobile
      session[:mobile_view].should be_true
    end
  end
end
