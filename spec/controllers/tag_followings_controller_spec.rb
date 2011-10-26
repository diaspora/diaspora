#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe TagFollowingsController do

  def valid_attributes
    {:name => "partytimeexcellent"}
  end

  before do
    @tag = ActsAsTaggableOn::Tag.create!(:name => "partytimeexcellent")
    sign_in :user, bob
  end

  describe 'index' do
    it 'assings new TagStream' do
      get :index
      assigns[:stream].should be_a Stream::FollowedTag
    end

    it 'renders a view' do
      get :index
      response.body.should_not be_blank
    end
  end

  describe "create" do
    describe "with valid params" do
      it "creates a new TagFollowing" do
        expect {
          post :create, valid_attributes
        }.to change(TagFollowing, :count).by(1)
      end

      it "assigns a newly created tag_following as @tag_following" do
        post :create, valid_attributes
        assigns(:tag_following).should be_a(TagFollowing)
        assigns(:tag_following).should be_persisted
      end

      it 'creates the tag if it does not already exist' do
        expect {
          post :create, :name => "tomcruisecontrol"
        }.to change(ActsAsTaggableOn::Tag, :count).by(1)
      end

      it 'does not create the tag following for non signed in user' do
        expect {
          post :create, valid_attributes.merge(:user_id => alice.id)
        }.to_not change(alice.tag_followings, :count).by(1)
      end

      it "flashes success to the tag page" do
        post :create, valid_attributes

        flash[:notice].should == "Successfully following: ##{valid_attributes[:name]}"
      end

      it "flashes error if you already have a tag" do
        TagFollowing.any_instance.stub(:save).and_return(false)
        post :create, valid_attributes

        flash[:error].should == "Failed to follow: ##{valid_attributes[:name]}"
      end

      it 'downcases the tag name' do
        pending "THIS CAUSES A 500 WE NEED TO FIX IT"
        post "tags/#{valid_attributes[:name].upcase}/tag_followings"
        assigns[:tag].should == @tag
      end
    end
  end

  describe "DELETE destroy" do
    before do
      TagFollowing.create!(:tag => @tag, :user => bob )
      TagFollowing.create!(:tag => @tag, :user => alice )
    end

    it "destroys the requested tag_following" do
      expect {
        delete :destroy, valid_attributes
      }.to change(TagFollowing, :count).by(-1)
    end

    it "redirects and flashes error if you already don't follow the tag" do
      delete :destroy, valid_attributes

      response.should redirect_to(tag_path(:name => valid_attributes[:name]))
      flash[:notice].should == "Successfully stopped following: ##{valid_attributes[:name]}"
    end

    it "redirects and flashes error if you already don't follow the tag" do
      TagFollowing.any_instance.stub(:destroy).and_return(false)
      delete :destroy, valid_attributes

      response.should redirect_to(tag_path(:name => valid_attributes[:name]))
      flash[:error].should == "Failed to stop following: ##{valid_attributes[:name]}"
    end
  end

  describe "#create_multiple" do
    it "adds multiple tags" do
      lambda{
        post :create_multiple, :tags => "#tags,#cats,#bats,"
      }.should change{
        bob.followed_tags.count
      }.by(3)
    end

    it "adds non-followed tags" do
      TagFollowing.create!(:tag => @tag, :user => bob )

      lambda{
        post :create_multiple, :tags => "#partytimeexcellent,#cats,#bats,"
      }.should change{
        bob.followed_tags.count
      }.by(2)

      response.should be_redirect
    end
  end

end
