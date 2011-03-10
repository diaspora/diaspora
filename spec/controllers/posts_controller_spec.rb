#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostsController do
  render_views

  before do
    @user = alice
  end
  describe '#index' do
    context 'signed in' do
      before do
        sign_in :user, @user
      end
      it 'works' do
        get :index
        response.status.should == 200
      end
    end
    it 'shows the most recent public posts' do
      posts = []
      10.times do
        posts << @user.post(:status_message, :message => "hello", :public => true, :to => 'all')
      end
      get :index
      assigns[:posts].should =~ posts
    end
    it' shows only local posts' do
      10.times do
        @user.post(:status_message, :message => "hello", :public => true, :to => 'all')
      end
      @user.person.update_attributes(:owner_id => nil)
      get :index
      assigns[:posts].should == []
    end
  end
  describe '#show' do
    it 'shows a public post' do
      status = @user.post(:status_message, :message => "hello", :public => true, :to => 'all')

      get :show, :id => status.id
      response.status= 200
    end

    it 'does not show a private post' do
      status = @user.post(:status_message, :message => "hello", :public => false, :to => 'all')
      get :show, :id => status.id
      response.status = 302
    end
  end
end
