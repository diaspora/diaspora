#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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
end
