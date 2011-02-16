#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


require 'spec_helper'

describe ContactsController do
  render_views

  before do
    @user = alice
    sign_in :user, @user
  end

  describe 'new' do

    it 'succeeds' do
      pending "This is going to be new request"
      get :new
      response.should be_success
    end
  end
end
