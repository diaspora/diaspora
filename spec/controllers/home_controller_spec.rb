#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe HomeController do
  describe '#show' do
    it 'does not redirect' do
      get :show
      response.should_not be_redirect
    end

    it 'redirects to multis index if user is logged in' do
      sign_in alice
      get :show, :home => true
      response.should redirect_to(multi_stream_path)
    end
  end
end
