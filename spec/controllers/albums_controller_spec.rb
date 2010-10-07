#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AlbumsController do
 render_views
  before do
    @user = Factory.create(:user)
    @aspect = @user.aspect(:name => "lame-os")
    @album = @user.post :album, :to => @aspect.id, :name => 'things on fire'
    sign_in :user, @user
  end

  it "should update the name of an album" do
    sign_in :user, @user
    put :update, :id => @album.id, :album => { :name => "new_name"}
    @album.reload.name.should eql("new_name")
  end

  describe '#create' do
    it 'all aspects' do
      params = {"album" => {"name" => "Sunsets","to" => "all"}}
      post :create, params
    end
    it 'one aspect' do
      params = {"album" => {"name" => "Sunsets","to" => @aspect.id.to_s}}
      post :create, params
    end
  end
end
