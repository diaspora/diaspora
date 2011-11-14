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
    bob.followed_tags.create(:name => "testing")
  end

  describe 'index' do
    it 'succeeds' do
      get :index
      response.should be_success
    end

    it 'assigns a stream' do
      get :index
      assigns[:stream].should be_a Stream::FollowedTag
    end
  end

  describe "create" do
    describe "successfully" do
      it "creates a new TagFollowing" do
        expect {
          post :create, valid_attributes
          response.should be_redirect
        }.to change(TagFollowing, :count).by(1)
      end

      it "associates the tag following with the currently-signed-in user" do
        expect {
          post :create, valid_attributes
        response.should be_redirect
        }.to change(bob.tag_followings, :count).by(1)
      end

      it "assigns a newly created tag_following as @tag_following" do
        post :create, valid_attributes
        response.should be_redirect
        assigns(:tag_following).should be_a(TagFollowing)
        assigns(:tag_following).should be_persisted
      end

      it "creates the tag IFF it doesn't already exist" do
        ActsAsTaggableOn::Tag.find_by_name('tomcruisecontrol').should be_nil
        expect {
          post :create, :name => "tomcruisecontrol"
        }.to change(ActsAsTaggableOn::Tag, :count).by(1)
      end

      it "flashes success to the tag page" do
        post :create, valid_attributes
        flash[:notice].should include(valid_attributes[:name])
      end

      it "flashes error if you already have a tag" do
        TagFollowing.any_instance.stub(:save).and_return(false)
        post :create, valid_attributes
        flash[:error].should include(valid_attributes[:name])
      end

      it 'squashes the tag' do
        ActsAsTaggableOn::Tag.find_by_name('somestuff').should be_nil
        post :create, :name => "some stuff"
        assigns[:tag].name.should == "somestuff"
        ActsAsTaggableOn::Tag.find_by_name('somestuff').should_not be_nil
      end

      it 'downcases the tag name' do
        ActsAsTaggableOn::Tag.find_by_name('somestuff').should be_nil
        post :create, :name => "SOMESTUFF"
        response.should be_redirect
        assigns[:tag].name.should == "somestuff"
        ActsAsTaggableOn::Tag.find_by_name('somestuff').should_not be_nil
      end

      it "normalizes the tag name" do
        ActsAsTaggableOn::Tag.find_by_name('foobar').should be_nil
        post :create, :name => "foo:bar"
        assigns[:tag].name.should == "foobar"
        ActsAsTaggableOn::Tag.find_by_name('foobar').should_not be_nil
      end
    end

    describe 'fails to' do
      it "create the tag if it already exists" do
        ActsAsTaggableOn::Tag.find_by_name('tomcruisecontrol').should be_nil
        expect {
          post :create, :name => "tomcruisecontrol"
        }.to change(ActsAsTaggableOn::Tag, :count).by(1)
        ActsAsTaggableOn::Tag.find_by_name('tomcruisecontrol').should_not be_nil

        expect {
          post :create, :name => "tomcruisecontrol"
        }.to change(ActsAsTaggableOn::Tag, :count).by(0)
        expect {
          post :create, :name => "tom cruise control"
        }.to change(ActsAsTaggableOn::Tag, :count).by(0)
        expect {
          post :create, :name => "TomCruiseControl"
        }.to change(ActsAsTaggableOn::Tag, :count).by(0)
        expect {
          post :create, :name => "tom:cruise:control"
        }.to change(ActsAsTaggableOn::Tag, :count).by(0)
      end

      it "create a tag following for a user other than the currently signed in user" do
        expect {
          expect {
            post :create, valid_attributes.merge(:user_id => alice.id)
          }.not_to change(alice.tag_followings, :count).by(1)
        }.to change(bob.tag_followings, :count).by(1)
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
      flash[:notice].should include(valid_attributes[:name])
    end

    it "redirects and flashes error if you already don't follow the tag" do
      TagFollowing.any_instance.stub(:destroy).and_return(false)
      delete :destroy, valid_attributes

      response.should redirect_to(tag_path(:name => valid_attributes[:name]))
      flash[:error].should include(valid_attributes[:name])
    end
  end

  describe "#create_multiple" do
    it "redirects" do
      post :create_multiple, :tags => "#foo,#bar"
      response.should be_redirect
    end

    it "handles no tags parameter" do
      expect { post :create_multiple, :name => 'not tags' }.to_not raise_exception
    end

    it "adds multiple tags" do
      expect { post :create_multiple, :tags => "#tags,#cats,#bats," }.to change{ bob.followed_tags.count }.by(3)
    end

    it "adds non-followed tags" do
      TagFollowing.create!(:tag => @tag, :user => bob )
      expect { post :create_multiple, :tags => "#partytimeexcellent,#a,#b," }.to change{ bob.followed_tags.count }.by(2)
    end

    it "normalizes the tag names" do
      bob.followed_tags.delete_all
      post :create_multiple, :tags => "#foo:bar,#bar#foo"
      bob.followed_tags(true).map(&:name).should =~ ["foobar", "barfoo"]
    end
  end
end
