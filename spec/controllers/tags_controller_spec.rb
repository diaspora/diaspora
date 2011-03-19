#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe TagsController do
  render_views

  before do
    @user = alice
  end
  describe '#show' do
    context 'signed in' do
      before do
        sign_in :user, @user
      end
      it 'works' do
        get :show, :name => 'testing'
        response.status.should == 200
      end
    end

    it 'restricts the posts by tag' do
      posts = []
      2.times do
        posts << @user.post(:status_message, :text => "#what", :public => true, :to => 'all')
      end
      2.times do
        @user.post(:status_message, :text => "#hello", :public => true, :to => 'all')
      end

      get :show, :name => 'what'
      assigns[:posts].should =~ posts
    end
  end
end
