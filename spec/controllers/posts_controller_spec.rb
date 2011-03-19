#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostsController do
  render_views

  before do
    @user = alice
  end
  describe '#show' do
    it 'shows a public post' do
      status = @user.post(:status_message, :text => "hello", :public => true, :to => 'all')

      get :show, :id => status.id
      response.status= 200
    end

    it 'does not show a private post' do
      status = @user.post(:status_message, :text => "hello", :public => false, :to => 'all')
      get :show, :id => status.id
      response.status = 302
    end
  end
end
