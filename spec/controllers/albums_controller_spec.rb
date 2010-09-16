#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper
describe AlbumsController do
 render_views
  before do
    @user = Factory.create(:user)
    @user.aspect(:name => "lame-os")
    @album = Factory.create(:album)
    sign_in :user, @user
  end

  it "should update the name of an album" do
    sign_in :user, @user
    put :update, :id => @album._id, :album => { :name => "new_name"}
    @album.reload.name.should eql("new_name")
  end

end
