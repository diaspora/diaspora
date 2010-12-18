#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PhotosController do
  render_views

  let(:user)  {make_user}
  let(:user2) {make_user}

  let!(:aspect) { user.aspects.create(:name => 'winners') }
  let(:aspect2) { user2.aspects.create(:name => 'winners') }

  let(:filename)     { 'button.png' }
  let(:fixture_name) { File.join(File.dirname(__FILE__), '..', 'fixtures', filename) }
  let(:image)        { File.open(fixture_name) }
  let!(:photo)       { user.post(:photo, :user_file => image, :to => aspect.id) }
  let!(:photo2)      { user2.post(:photo, :user_file => image, :to => aspect2.id) }

  before do
    connect_users(user, aspect, user2, aspect2)
    sign_in :user, user
  end

  describe '#create' do
    before do
      @controller.stub!(:file_handler).and_return(image)
      @params = {:photo => {:user_file => image, :aspect_ids => "all"} }
    end

    it 'can make a photo' do
      lambda {
        post :create, @params
      }.should change(Photo, :count).by(1)
    end
    it 'can set the photo as the profile photo' do
      old_url = user.person.profile.image_url
      @params[:photo][:set_profile_photo] = true
      post :create, @params
      user.reload.person.profile.image_url.should_not == old_url
    end
  end

  describe '#index' do
    it 'defaults to returning all of users pictures' do
      get :index, :person_id => user.person.id.to_s
      assigns[:person].should == user.person
      assigns[:posts].should == [photo]
    end

    it 'sets the person to a contact if person_id is set' do
      get :index, :person_id => user2.person.id.to_s

      assigns[:person].should == user2.person
      assigns[:posts].should be_empty
    end
  end

  describe '#show' do
    it 'assigns the photo based on the photo id' do
      get :show, :id => photo.id
      response.status.should == 200

      assigns[:photo].should == photo
      assigns[:ownership].should be_true
    end

  end

  describe '#edit' do
    it 'lets the user edit a photo' do
      get :edit, :id => photo.id
      response.status.should == 200
    end

    it 'does not let the user edit a photo that is not his' do
      get :edit, :id => photo2.id
      response.should redirect_to(:action => :index, :person_id => user.person.id.to_s)
    end
  end


  describe '#destroy' do
    it 'allows the user to delete his photos' do
      delete :destroy, :id => photo.id
      Photo.find_by_id(photo.id).should be_nil
    end

    it 'will not let you destory posts you do not own' do
      delete :destroy, :id => photo2.id
      Photo.find_by_id(photo2.id).should be_true
    end
  end

  describe "#update" do
    it "updates the caption of a photo" do
      put :update, :id => photo.id, :photo => { :caption => "now with lasers!" }
      photo.reload.caption.should == "now with lasers!"
    end

    it "doesn't overwrite random attributes" do
      new_user = Factory.create :user
      params = { :caption => "now with lasers!", :person_id => new_user.id }
      put :update, :id => photo.id, :photo => params
      photo.reload.person_id.should == user.person.id
    end

    it 'redirects if you do not have access to the post' do
      params = { :caption => "now with lasers!" }
      put :update, :id => photo2.id, :photo => params
      response.should redirect_to(:action => :index, :person_id => user.person.id.to_s)
    end
  end

  describe "#make_profile_photo" do

    it 'should return a 201 on a js success' do
      get :make_profile_photo, :photo_id => photo.id, :format => 'js'
      response.code.should == "201"
    end

    it 'should return a 406 on failure' do
      get :make_profile_photo, :photo_id => photo2.id
      response.code.should == "406"
    end

  end

end
