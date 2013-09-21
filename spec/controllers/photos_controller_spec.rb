#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PhotosController do
  before do
    @alices_photo = alice.post(:photo, :user_file => uploaded_photo, :to => alice.aspects.first.id, :public => false)
    @bobs_photo = bob.post(:photo, :user_file => uploaded_photo, :to => bob.aspects.first.id, :public => true)

    sign_in :user, alice
    request.env["HTTP_REFERER"] = ''
  end

  describe '#create' do
    before do
      @params = {
        :photo => {:aspect_ids => "all"},
        :qqfile => Rack::Test::UploadedFile.new(
          Rails.root.join("spec", "fixtures", "button.png").to_s,
          "image/png"
        )
      }
    end

    it 'accepts a photo from a regular form submission' do
      lambda {
        post :create, @params
      }.should change(Photo, :count).by(1)
    end

    it 'returns application/json when possible' do
      request.env['HTTP_ACCEPT'] = 'application/json'
      post(:create, @params).headers['Content-Type'].should match 'application/json.*'
    end

    it 'returns text/html by default' do
      request.env['HTTP_ACCEPT'] = 'text/html,*/*'
      post(:create, @params).headers['Content-Type'].should match 'text/html.*'
    end
  end

  describe '#create' do
    before do
      @controller.stub(:file_handler).and_return(uploaded_photo)
      @params = {:photo => {:user_file => uploaded_photo, :aspect_ids => "all"} }
    end

    it "creates a photo" do
      lambda {
        post :create, @params
      }.should change(Photo, :count).by(1)
    end

    it "doesn't allow mass assignment of person" do
      new_user = FactoryGirl.create(:user)
      @params[:photo][:author] = new_user
      post :create, @params
      Photo.last.author.should == alice.person
    end

    it "doesn't allow mass assignment of person_id" do
      new_user = FactoryGirl.create(:user)
      @params[:photo][:author_id] = new_user.id
      post :create, @params
      Photo.last.author.should == alice.person
    end

    it 'can set the photo as the profile photo' do
      old_url = alice.person.profile.image_url
      @params[:photo][:set_profile_photo] = true
      post :create, @params
      alice.reload.person.profile.image_url.should_not == old_url
    end
  end

  describe '#index' do
    it "succeeds without any available pictures" do
      get :index, :person_id => FactoryGirl.create(:person).guid.to_s

      response.should be_success
    end

    it "displays the logged in user's pictures" do
      get :index, :person_id => alice.person.guid.to_s
      assigns[:person].should == alice.person
      assigns[:posts].should == [@alices_photo]
    end

    it "displays another person's pictures" do
      get :index, :person_id => bob.person.guid.to_s
      assigns[:person].should == bob.person
      assigns[:posts].should == [@bobs_photo]
    end

    it "returns json when requested" do
      request.env['HTTP_ACCEPT'] = 'application/json'
      get :index, :person_id => alice.person.guid.to_s

      response.headers['Content-Type'].should match 'application/json.*'
      save_fixture(response.body, "photos_json")
    end
    
    it 'displays by date of creation' do
      max_time = bob.photos.first.created_at - 1.day
      get :index, person_id: bob.person.guid.to_s, 
                  max_time: max_time.to_i

      assigns[:posts].should be_empty
    end
  end

  describe '#edit' do
    it "succeeds when user owns the photo" do
      get :edit, :id => @alices_photo.id
      response.should be_success
    end

    it "redirects when the user does not own the photo" do
      get :edit, :id => @bobs_photo.id
      response.should redirect_to(:action => :index, :person_id => alice.person.guid.to_s)
    end
  end

  describe '#destroy' do
    it 'let a user delete his message' do
      delete :destroy, :id => @alices_photo.id
      Photo.find_by_id(@alices_photo.id).should be_nil
    end

    it 'will let you delete your profile picture' do
      get :make_profile_photo, :photo_id => @alices_photo.id, :format => :js
      delete :destroy, :id => @alices_photo.id
      Photo.find_by_id(@alices_photo.id).should be_nil
    end

    it 'sends a retraction on delete' do
      @controller.stub(:current_user).and_return(alice)
      alice.should_receive(:retract).with(@alices_photo)
      delete :destroy, :id => @alices_photo.id
    end

    it 'will not let you destroy posts visible to you' do
      delete :destroy, :id => @bobs_photo.id
      Photo.find_by_id(@bobs_photo.id).should be_true
    end

    it 'will not let you destroy posts you do not own' do
      eves_photo = eve.post(:photo, :user_file => uploaded_photo, :to => eve.aspects.first.id, :public => true)
      delete :destroy, :id => eves_photo.id
      Photo.find_by_id(eves_photo.id).should be_true
    end
  end

  describe "#update" do
    it "updates the caption of a photo" do
      put :update, :id => @alices_photo.id, :photo => { :text => "now with lasers!" }, :format => :js
      @alices_photo.reload.text.should == "now with lasers!"
    end

    it "doesn't allow mass assignment of person" do
      new_user = FactoryGirl.create(:user)
      params = { :text => "now with lasers!", :author => new_user }
      put :update, :id => @alices_photo.id, :photo => params, :format => :js
      @alices_photo.reload.author.should == alice.person
    end

    it "doesn't allow mass assignment of person_id" do
      new_user = FactoryGirl.create(:user)
      params = { :text => "now with lasers!", :author_id => new_user.id }
      put :update, :id => @alices_photo.id, :photo => params, :format => :js
      @alices_photo.reload.author_id.should == alice.person.id
    end

    it 'redirects if you do not have access to the post' do
      params = { :text => "now with lasers!" }
      put :update, :id => @bobs_photo.id, :photo => params
      response.should redirect_to(:action => :index, :person_id => alice.person.guid.to_s)
    end
  end

  describe "#make_profile_photo" do
    it 'should return a 201 on a js success' do
      get :make_profile_photo, :photo_id => @alices_photo.id, :format => 'js'
      response.code.should == "201"
    end

    it 'should return a 422 on failure' do
      get :make_profile_photo, :photo_id => @bobs_photo.id
      response.code.should == "422"
    end
  end

  describe "#show" do
    it 'should return 404 for nonexistent stuff on mobile devices' do
      expect {
        get :show, :person_id => bob.person.guid, :id => 772831, :format => 'mobile'
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'should return 200 for existing stuff on mobile devices' do
      get :show, :person_id => alice.person.guid, :id => @alices_photo.id, :format => 'mobile'
      response.should be_success
    end

    it "doesn't leak private photos to the public" do
      sign_out :user
      expect {
        get :show, :person_id => alice.person.guid, :id => @alices_photo.id, :format => 'mobile'
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

end
