#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AlbumsController do
 render_views
  before do
    @user = make_user
    @aspect = @user.aspect(:name => "lame-os")
    @album = @user.post :album, :to => @aspect.id, :name => 'things on fire'
    sign_in :user, @user
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

  describe "#update" do
    it "should update the name of an album" do
      put :update, :id => @album.id, :album => { :name => "new_name"}
      @album.reload.name.should eql("new_name")
    end
    
    it "doesn't overwrite random attributes" do
      new_user = make_user
      params = {:name => "Bruisers", :person_id => new_user.person.id}
      put('update', :id => @album.id, "album" => params)
      @album.reload.person_id.should == @user.person.id
      @album.name.should == 'Bruisers'
    end
  end
end
