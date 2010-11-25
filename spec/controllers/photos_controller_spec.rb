#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PhotosController do
  let(:user)         { make_user }
  let(:user2)        { make_user }

  let!(:aspect)      { user.aspects.create(:name => 'winners') }
  let(:aspect2)      { user2.aspects.create(:name => 'winners') }

  let(:filename)     { 'button.png' }
  let(:fixture_name) { File.join(File.dirname(__FILE__), '..', 'fixtures', filename) }
  let(:image)        { File.open(fixture_name) }
  let!(:photo)       { user.post(:photo, :user_file => image, :to => aspect.id) }
  let!(:photo2)      { user2.post(:photo, :user_file => image, :to => aspect2.id) }

  before do
    connect_users(user, aspect, user2, aspect2)
    sign_in :user, user
    @controller.stub!(:current_user) { user }
  end

  describe '#create' do
    before do
      @controller.stub!(:file_handler) { image }
    end

    it 'makes a photo' do
      pending do
        expect { post :create, :qqfile => fixture_name }.to change(Photo, :count).by(1)
      end
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

    it 'sets the aspect to profile' do
      get :index, :person_id => user.person.id.to_s
      assigns[:aspect].should == :profile
    end

  end

  describe '#show' do
    it 'assigns the photo based on the photo id' do
      get :show, :id => photo.id
      response.should be_successful

      assigns[:photo].should == photo
      assigns[:ownership].should be
    end

  end

  describe '#edit' do
    it 'should let you edit a photo' do
      get :edit, :id => photo.id
      response.should be_successful
    end

    it "doesn't allow to edit a photo that doesn't belong to the user" do
      get :edit, :id => photo2.id
      response.should redirect_to(:action => :index, :person_id => user.person.id.to_s)
    end
  end

  describe '#destroy' do
    it "allows deletion of user's photos" do
      delete :destroy, :id => photo.id
      Photo.find_by_id(photo.id).should be nil
    end

    it "doesn't allow to delete posts not owned by the user" do
      delete :destroy, :id => photo2.id
      Photo.find_by_id(photo2.id).should be
    end
  end

  describe "#update" do
    it "updates the caption of a photo" do
      put :update, :id => photo.id, :photo => { :caption => "now with lasers!" }
      photo.reload.caption.should == "now with lasers!"
    end

    it "doesn't overwrite random attributes" do
      new_user = Factory.create :user
      params = { :caption => "now with lasers!", :person_id => new_user.id}
      put :update, :id => photo.id, :photo => params
      photo.reload.person_id.should == user.person.id
    end

    it "redirects if the user doesn't have access to the post" do
      params = { :caption => "now with lasers!"}
      put :update, :id => photo2.id, :photo => params
      response.should redirect_to(:action => :index, :person_id => user.person.id.to_s)

    end
  end
end
