#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PhotosController do
  render_views
  before do
    @user = Factory.create(:user)
    @aspect = @user.aspect(:name => "lame-os")
    @album = @user.post :album, :to => @aspect.id, :name => 'things on fire'
    @fixture_filename = 'button.png'
    @fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', @fixture_filename)
    image = File.open(@fixture_name)
    #@photo = Photo.instantiate(
     #         :person => @user.person, :album => @album, :user_file => image)
    @photo  = @user.post(:photo, :album_id => @album.id, :user_file => image, :to => @aspect.id)
    sign_in :user, @user
  end

  describe '#create' do
  end

  describe "#update" do
    it "should update the caption of a photo" do
      put :update, :id => @photo.id, :photo => { :caption => "now with lasers!"}
      @photo.reload.caption.should == "now with lasers!"
    end
    
    it "doesn't overwrite random attributes" do
      new_user = Factory.create :user
      params = { :caption => "now with lasers!", :person_id => new_user.id}
      put :update, :id => @photo.id, :photo => params
      @photo.reload.person_id.should == @user.person.id
    end
  end
end
