#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe TagsController do
  render_views

  before do
    @user = alice
  end
  
  describe '#index (search)' do
    before do
      sign_in :user, @user
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
  end
  
  describe '#show' do


    context 'signed in' do
      before do
        sign_in :user, @user
      end
      it 'works' do
        get :show, :name => 'testing'
        response.status.should == 200
      end
    end

    context "not signed in" do
      context "when there are people to display" do
        before do
          @user.profile.tag_string = "#whatevs"
          @user.profile.build_tags
          @user.profile.save!
          get :show, :name => "whatevs"
        end
        it "succeeds" do
          response.should be_success
        end
        it "assigns the right set of people" do
          assigns(:people).should == [@user.person]
        end
      end
      context "when there are posts to display" do
        before do
          @post = @user.post(:status_message, :text => "#what", :public => true, :to => 'all')
          @user.post(:status_message, :text => "#hello", :public => true, :to => 'all')
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
          @user.comment('what WHAT!', :on => @post)
          get :show, :name => 'what'
          response.should be_success
        end
      end
    end
  end
end
