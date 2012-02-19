#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PhotosController do
  before do
    @alices_photo = alice.post(:photo, :user_file => uploaded_photo, :to => alice.aspects.first.id)
    @bobs_photo = bob.post(:photo, :user_file => uploaded_photo, :to => bob.aspects.first.id, :public => true)

    @controller.stub!(:current_user).and_return(alice)
    sign_in :user, alice
    request.env["HTTP_REFERER"] = ''
  end

  describe '#create' do
    before do
      @params = {
        :photo => {:aspect_ids => "all"},
        :qqfile => Rack::Test::UploadedFile.new(
          File.join( Rails.root, "spec/fixtures/button.png" ),
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
      @controller.stub!(:file_handler).and_return(uploaded_photo)
      @params = {:photo => {:user_file => uploaded_photo, :aspect_ids => "all"} }
    end

    it "creates a photo" do
      lambda {
        post :create, @params
      }.should change(Photo, :count).by(1)
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
      get :index, :person_id => Factory(:person).guid.to_s

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
  end

  describe '#show' do
    context "user's own photo" do
      before do
        get :show, :id => @alices_photo.id
      end

      it "succeeds" do
        response.should be_success
      end

      it "assigns the photo" do
        assigns[:photo].should == @alices_photo
        @controller.ownership.should be_true
      end
    end

    context "private photo user can see" do
      it "succeeds" do
        get :show, :id => @bobs_photo.id
        response.should be_success
      end

      it "assigns the photo" do
        get :show, :id => @bobs_photo.id
        assigns[:photo].should == @bobs_photo
        @controller.ownership.should be_false
      end

      it 'succeeds with a like present' do
        sm = bob.post(:status_message, :text => 'parent post', :to => 'all')
        @bobs_photo.status_message_guid = sm.guid
        @bobs_photo.save!
        alice.like!(@bobs_photo.status_message)
        get :show, :id => @bobs_photo.id
        response.should be_success
      end
    end

    context "private photo user cannot see" do
      before do
        user3 = Factory(:user_with_aspect)
        @photo = user3.post(:photo, :user_file => uploaded_photo, :to => user3.aspects.first.id)
      end

      it "redirects to the referrer" do
        request.env["HTTP_REFERER"] = "http://google.com"
        get :show, :id => @photo.to_param
        response.should redirect_to("http://google.com")
      end

      it "redirects to the aspects page if there's no referrer" do
        request.env.delete("HTTP_REFERER")
        get :show, :id => @photo.to_param
        response.should redirect_to(root_path)
      end
      
      it 'redirects to the sign in page if not logged in' do
        controller.stub(:user_signed_in?).and_return(false) #sign_out :user doesn't work
        get :show, :id => @photo.to_param
        response.should redirect_to new_user_session_path
      end
    end

    context "public photo" do
      before do
        user3 = Factory(:user_with_aspect)
        @photo = user3.post(:photo, :user_file => uploaded_photo, :to => user3.aspects.first.id, :public => true)
      end
      context "user logged in" do
        before do
          get :show, :id => @photo.to_param
        end

        it "succeeds" do
          response.should be_success
        end

        it "assigns the photo" do
          assigns[:photo].should == @photo
          @controller.ownership.should be_false
        end
      end
      context "not logged in" do
        before do
          sign_out :user
          get :show, :id => @photo.to_param
        end

        it "succeeds" do
          response.should be_success
        end

        it "assigns the photo" do
          assigns[:photo].should == @photo
        end
      end
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
      get :make_profile_photo, :photo_id => @alices_photo.id
      delete :destroy, :id => @alices_photo.id
      Photo.find_by_id(@alices_photo.id).should be_nil
    end

    it 'sends a retraction on delete' do
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
      put :update, :id => @alices_photo.id, :photo => { :text => "now with lasers!" }
      @alices_photo.reload.text.should == "now with lasers!"
    end

    it "doesn't overwrite random attributes" do
      new_user = Factory(:user)
      params = { :text => "now with lasers!", :author_id => new_user.id }
      put :update, :id => @alices_photo.id, :photo => params
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


  describe 'data helpers' do
    describe '.ownership' do
      it 'is true if current user owns the photo' do
        get :show, :id => @alices_photo.id
        @controller.ownership.should be_true
      end

      it 'is true if current user owns the photo' do
        get :show, :id => @bobs_photo.id
        @controller.ownership.should be_false
      end
    end

    describe 'parent' do
      it 'grabs the status message of the photo if a parent exsists' do
        sm = alice.post(:status_message, :text => 'yes', :to => alice.aspects.first)
        @alices_photo.status_message = sm
        @alices_photo.save
        get :show, :id => @alices_photo.id
        @controller.parent.id.should == sm.id
      end

      it 'uses the photo if no status_message exsists' do
        get :show, :id => @alices_photo.id
        @controller.parent.id.should == @alices_photo.id
      end
    end

    describe '.photo' do
      it 'returns a visible photo, based on the :id param' do
        get :show, :id => @alices_photo.id
        @controller.photo.id.should == @alices_photo.id

      end
    end

    describe '.additional_photos' do
      it 'finds all of a parent status messages photos' do
        sm = alice.post(:status_message, :text => 'yes', :to => alice.aspects.first)
        @alices_photo.status_message = sm
        @alices_photo.save
        get :show, :id => @alices_photo.id
        @controller.additional_photos.should include(@alices_photo)
      end
    end

    describe '.next_photo' do

    end

    describe '.previous_photo' do

    end
  end
end
