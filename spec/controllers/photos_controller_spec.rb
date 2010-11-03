#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PhotosController do
  let(:user) {make_user}
  let(:user2) {make_user}

  let!(:aspect) {user.aspects.create(:name => 'winners')}
  let(:aspect2) {user2.aspects.create(:name => 'winners')}
  
  let!(:album) {user.post(:album, :to => aspect.id, :name => "room on fire")}
  let!(:album2) {user2.post(:album, :to => aspect2.id, :name => "room on fire")}
  let(:filename) {'button.png'}
  let(:fixture_name) {File.join(File.dirname(__FILE__), '..', 'fixtures', filename)}
  let(:image) {File.open(fixture_name)}
  let!(:photo){ user.post(:photo, :album_id => album.id, :user_file => image, :to => aspect.id)}
  let(:photo_no_album){ user.post(:photo, :user_file => image, :to => aspect.id)}
  let!(:photo2){ user2.post(:photo, :album_id => album2.id, :user_file => image, :to => aspect2.id)}

  before do
    friend_users(user, aspect, user2, aspect2)
    sign_in :user, user
    user.reload
    aspect.reload
    aspect2.reload
    @controller.stub!(:current_user).and_return(user)
  end

  describe '#create' do
    let(:foo) {{:album_id => album.id.to_s}}

    before do
      @controller.stub!(:file_handler).and_return(image)
    end
    it 'can make a photo in an album' do
      pending
      proc{ post :create, :photo => foo, :qqfile => fixture_name }.should change(Photo, :count).by(1)
    end

    it 'can make a picture without an album' do
      pending
    end

    it 'does not let you create a photo in an album you do not own' do
      pending
    end
  end

  describe '#index' do
    it 'defaults to returning all of users pictures' do
      get :index
      assigns[:person].should == user.person
      assigns[:photos].should == [photo]
      assigns[:albums].should == [album]
    end

    it 'sets the person to a friend if person_id is set' do
      get :index, :person_id => user2.person.id  
      
      assigns[:person].should == user2.person
      assigns[:photos].should == []
      assigns[:albums].should == []
    end

    it 'sets the aspect to photos?' do
      get :index
      assigns[:aspect].should == :photos
    end
    
  end

  describe '#show' do
    it 'assigns the photo based on the photo id' do
      get :show, :id => photo.id

      assigns[:photo].should == photo
      assigns[:album].should == album
      assigns[:ownership].should == true 
    end

  end

  describe '#edit' do
    it 'should let you edit a photo with an album' do
      get :edit, :id => photo.id 
      response.code.should == "200"
    end

    it 'should let you edit a photo you own that does not have an album' do
      get :edit, :id => photo_no_album.id 
      response.code.should == "200"
    end

    it 'should not let you edit a photo that is not yours' do
      get :edit, :id => photo2.id 
      response.should redirect_to(:action => :index)
    end
  end


  describe '#destroy' do
    it 'should let me delete my photos' do
      delete :destroy, :id => photo.id
      Photo.find_by_id(photo.id).should be nil
    end

    it 'will not let you destory posts you do not own' do
      delete :destroy, :id => photo2.id
      Photo.find_by_id(photo2.id).should_not be nil
    end
  end

  describe "#update" do
    it "should update the caption of a photo" do
      put :update, :id => photo.id, :photo => { :caption => "now with lasers!"}
      photo.reload.caption.should == "now with lasers!"
    end
    
    it "doesn't overwrite random attributes" do
      new_user = Factory.create :user
      params = { :caption => "now with lasers!", :person_id => new_user.id}
      put :update, :id => photo.id, :photo => params
      photo.reload.person_id.should == user.person.id
    end

    it 'should redirect if you do not have access to the post' do
      params = { :caption => "now with lasers!"}
      put :update, :id => photo2.id, :photo => params
      response.should redirect_to(:action => :index)
    end
  end
end
