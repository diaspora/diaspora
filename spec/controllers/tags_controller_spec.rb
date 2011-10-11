#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe TagsController do
  describe '#index (search)' do
    before do
      sign_in :user, alice
      bob.profile.tag_string = "#cats #diaspora #rad"
      bob.profile.build_tags
      bob.profile.save!
    end

    it 'responds with json' do
      get :index, :q => "ra", :format => 'json'
      #parse json
      response.body.should include("#rad")
    end

    it 'requires at least two characters' do
      get :index, :q => "c", :format => 'json'
      response.body.should_not include("#cats")
    end

    it 'redirects the aimless to excellent parties' do
      get :index
      response.should redirect_to tag_path('partytimeexcellent')
    end

    it 'does not allow json requestors to party' do
      get :index, :format => :json
      response.status.should == 422
    end
  end

  describe '#show' do
    context 'signed in' do
      before do
        sign_in :user, alice
      end

      it 'displays your own post' do
        my_post = alice.post(:status_message, :text => "#what", :to => 'all')
        get :show, :name => 'what'
        assigns(:posts).should == [my_post]
        response.status.should == 200
      end

      it "displays a friend's post" do
        other_post = bob.post(:status_message, :text => "#hello", :to => 'all')
        get :show, :name => 'hello'
        assigns(:posts).should == [other_post]
        response.status.should == 200
      end

      it 'displays a public post' do
        other_post = eve.post(:status_message, :text => "#hello", :public => true, :to => 'all')
        get :show, :name => 'hello'
        assigns(:posts).should == [other_post]
        response.status.should == 200
      end

      it 'displays a public post that was sent to no one' do
        stranger = Factory(:user_with_aspect)
        stranger_post = stranger.post(:status_message, :text => "#hello", :public => true, :to => 'all')
        get :show, :name => 'hello'
        assigns(:posts).should == [stranger_post]
      end

      it 'displays a post with a comment containing the tag search' do
        pending "toooo slow"
        bob.post(:status_message, :text => "other post y'all", :to => 'all')
        other_post = bob.post(:status_message, :text => "sup y'all", :to => 'all')
        Factory(:comment, :text => "#hello", :post => other_post)
        get :show, :name => 'hello'
        assigns(:posts).should == [other_post]
        response.status.should == 200
      end

      it 'succeeds without posts' do
        get :show, :name => 'hellyes'
        response.status.should == 200
      end
    end

    context "not signed in" do
      context "when there are people to display" do
        before do
          alice.profile.tag_string = "#whatevs"
          alice.profile.build_tags
          alice.profile.save!
          get :show, :name => "whatevs"
        end

        it "succeeds" do
          response.should be_success
        end

        it "assigns the right set of people" do
          assigns(:people).should == [alice.person]
        end
      end

      context "when there are posts to display" do
        before do
          @post = alice.post(:status_message, :text => "#what", :public => true, :to => 'all')
          alice.post(:status_message, :text => "#hello", :public => true, :to => 'all')
        end

        it "succeeds" do
          get :show, :name => 'what'
          response.should be_success
        end

        it "assigns the right set of posts" do
          get :show, :name => 'what'
          assigns[:posts].should == [@post]
        end

        it 'succeeds with comments' do
          alice.comment('what WHAT!', :post => @post)
          get :show, :name => 'what'
          response.should be_success
        end
      end
    end
  end

  context 'helper methods' do
    describe 'tag_followed?' do
      before do
        sign_in bob
        @tag = ActsAsTaggableOn::Tag.create!(:name => "partytimeexcellent")
        @controller.stub(:current_user).and_return(bob)
        @controller.stub(:params).and_return({:name => "partytimeexcellent"})
      end

      it 'returns true if the following already exists' do
        TagFollowing.create!(:tag => @tag, :user => bob )
        @controller.tag_followed?.should be_true
      end

      it 'returns false if the following does not already exist' do
        @controller.tag_followed?.should be_false
      end
    end
  end
end
