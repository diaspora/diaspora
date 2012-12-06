#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      head :ok
    end
  end

  before do
    sign_in alice
  end

  describe '#set_diaspora_headers' do
    it 'sets the version header' do
      get :index
      response.headers['X-Diaspora-Version'].should include AppConfig.version.number.get
    end
    
    context 'with git info' do
      before do
        AppConfig.stub(:git_available?).and_return(true)
        AppConfig.stub(:git_update).and_return('yesterday')
        AppConfig.stub(:git_revision).and_return('02395')
      end

      it 'sets the git header' do
        get :index
        response.headers['X-Git-Update'].should == 'yesterday'
        response.headers['X-Git-Revision'].should == '02395'
      end
    end
  end

  describe '#mobile_switch' do
    it 'sets the format to :mobile' do
      request.format = :html
      session[:mobile_view] = true
      get :index
      request.format.mobile?.should be_true
    end

    it 'uses :html for :tablets' do
      request.format = :tablet
      session[:tablet_view] = true
      get :index
      request.format.html?.should be_true
    end

    it "doesn't mess up other formats, like json" do
      get :index, :format => 'json'
      request.format.json?.should be_true
    end

    it "doesn't mess up other formats, like xml, even with :mobile session" do
      session[:mobile_view] = true
      get :index, :format => 'xml'
      request.format.xml?.should be_true
    end
  end

  describe '#tags' do
    before do
      @tag = ActsAsTaggableOn::Tag.create!(:name => "partytimeexcellent")
      TagFollowing.create!(:tag => @tag, :user => alice)
    end

    it 'queries current_users tag if there are tag_followings' do
      @controller.send(:tags).should == [@tag]
    end

    it 'does not query twice' do
      User.any_instance.should_receive(:followed_tags).once.and_return([@tag])
      @controller.send(:tags)
      @controller.send(:tags)
    end
  end

  describe "#after_sign_in_path_for" do
    context 'getting started true on user' do
      before do
        alice.update_attribute(:getting_started, true)
      end

      it "redirects to getting started if the user has getting started set to true" do
        @controller.send(:after_sign_in_path_for, alice).should == getting_started_path
      end
    end
  end
end
