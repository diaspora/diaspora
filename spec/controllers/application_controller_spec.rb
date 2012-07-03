#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ApplicationController do
  controller do
    def user_signed_in?
      nil
    end

    def current_user
      nil
    end

    def index
      render :nothing => true
    end
  end

  describe '#set_git_headers' do
    context 'with git info' do
      before do
        AppConfig[:git_update] = 'yesterday'
        AppConfig[:git_revision] = '02395'
      end

      it 'sets the git header if there is git info' do
        get :index
        response.headers['X-Git-Update'].should == 'yesterday'
        response.headers['X-Git-Revision'].should == '02395'
      end
    end
  end

  describe '#mobile_switch' do
    it 'sets the format to :mobile' do
      request.format = :html
      session[:mobile_view] = true
      get :index
      request.format.mobile?.should be_true
    end

    it 'uses :html for :tablets' do
      request.format = :tablet
      session[:tablet_view] = true
      get :index
      request.format.html?.should be_true
    end

    it "doesn't mess up other formats, like json" do
      get :index, :format => 'json'
      request.format.json?.should be_true
    end

    it "doesn't mess up other formats, like xml, even with :mobile session" do
      session[:mobile_view] = true
      get :index, :format => 'xml'
      request.format.xml?.should be_true
    end
  end
end
