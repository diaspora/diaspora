#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe TagsController do
  render_views

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
      response.body.should include("#diaspora")
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
        assigns(:posts).models.should == [my_post]
        response.status.should == 200
      end
      it "displays a friend's post" do
        other_post = bob.post(:status_message, :text => "#hello", :to => 'all')
        get :show, :name => 'hello'
        assigns(:posts).models.should == [other_post]
        response.status.should == 200
      end
      it 'displays a public post' do
        other_post = eve.post(:status_message, :text => "#hello", :public => true, :to => 'all')
        get :show, :name => 'hello'
        assigns(:posts).models.should == [other_post]
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
          assigns[:posts].models.should == [@post]
        end
        it 'succeeds with comments' do
          alice.comment('what WHAT!', :on => @post)
          get :show, :name => 'what'
          response.should be_success
        end
      end
    end
  end
end
