#   Copyright (c) 2010, Diaspora Inc.  This file is
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

  describe "POST create" do
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

      it "redirects to the tag page" do
        post :create, valid_attributes
        response.should redirect_to(tag_path(:name => valid_attributes[:name]))
      end

      it "returns a 406 if you already have a tag" do
        TagFollowing.any_instance.stub(:save).and_return(false)
        post :create, valid_attributes
        response.code.should == "406"
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

    it "returns a 410 if you already have a tag" do
      TagFollowing.any_instance.stub(:destroy).and_return(false)
      delete :destroy, valid_attributes
      response.code.should == "410"
    end
  end

end
