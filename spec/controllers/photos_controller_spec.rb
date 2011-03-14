#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PhotosController do
  render_views

  before do
    @alice = alice
    @bob = bob

    @alices_photo = @alice.post(:photo, :user_file => uploaded_photo, :to => @alice.aspects.first.id)
    @bobs_photo = @bob.post(:photo, :user_file => uploaded_photo, :to => @bob.aspects.first.id, :public => true)

    @controller.stub!(:current_user).and_return(@alice)
    sign_in :user, @alice
    request.env["HTTP_REFERER"] = ''
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
      old_url = @alice.person.profile.image_url
      @params[:photo][:set_profile_photo] = true
      post :create, @params
      @alice.reload.person.profile.image_url.should_not == old_url
    end
  end

  describe '#index' do
    it "displays the logged in user's pictures" do
      get :index, :person_id => @alice.person.id.to_s
      assigns[:person].should == @alice.person
      assigns[:posts].should == [@alices_photo]
    end

    it "displays another person's pictures" do
      get :index, :person_id => @bob.person.id.to_s
      assigns[:person].should == @bob.person
      assigns[:posts].should == [@bobs_photo]
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
        assigns[:ownership].should be_true
      end
    end
    context "private photo user can see" do
      before do
        get :show, :id => @bobs_photo.id
      end
      it "succeeds" do
        response.should be_success
      end
      it "assigns the photo" do
        assigns[:photo].should == @bobs_photo
        assigns[:ownership].should be_false
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
        response.should redirect_to(aspects_path)
      end
    end
    context "public photo" do
      before do
        user3 = Factory(:user_with_aspect)
        @photo = user3.post(:photo, :user_file => uploaded_photo, :to => user3.aspects.first.id, :public => true)
        get :show, :id => @photo.to_param
      end
      it "succeeds" do
        response.should be_success
      end
      it "assigns the photo" do
        assigns[:photo].should == @photo
        assigns[:ownership].should be_false
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
      response.should redirect_to(:action => :index, :person_id => @alice.person.id.to_s)
    end
  end


  describe '#destroy' do
    it 'allows the user to delete his photos' do
      delete :destroy, :id => @alices_photo.id
      Photo.find_by_id(@alices_photo.id).should be_nil
    end

    it 'will not let you destory posts you do not own' do
      delete :destroy, :id => @bobs_photo.id
      Photo.find_by_id(@bobs_photo.id).should be_true
    end
  end

  describe "#update" do
    it "updates the caption of a photo" do
      put :update, :id => @alices_photo.id, :photo => { :text => "now with lasers!" }
      @alices_photo.reload.text.should == "now with lasers!"
    end

    it "doesn't overwrite random attributes" do
      new_user = Factory.create(:user)
      params = { :text => "now with lasers!", :author_id => new_user.id }
      put :update, :id => @alices_photo.id, :photo => params
      @alices_photo.reload.author_id.should == @alice.person.id
    end

    it 'redirects if you do not have access to the post' do
      params = { :text => "now with lasers!" }
      put :update, :id => @bobs_photo.id, :photo => params
      response.should redirect_to(:action => :index, :person_id => @alice.person.id.to_s)
    end
  end

  describe "#make_profile_photo" do

    it 'should return a 201 on a js success' do
      get :make_profile_photo, :photo_id => @alices_photo.id, :format => 'js'
      response.code.should == "201"
    end

    it 'should return a 406 on failure' do
      get :make_profile_photo, :photo_id => @bobs_photo.id
      response.code.should == "406"
    end

  end

end
