#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  render_views
  before do
    @user = Factory.create(:user)

    sign_in :user, @user
    @user.aspect(:name => "lame-os")
  end



  it 'should go to the current_user show page' do
    get :show, :id => @user.id
    
    response.should render_template "users/show"
    response.should be_success
  end
end
