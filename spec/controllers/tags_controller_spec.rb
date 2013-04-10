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
    context 'tag with capital letters' do
      before do
        sign_in :user, alice
      end

      it 'redirect to the downcase tag uri' do
        get :show, :name => 'DiasporaRocks!'
        response.should redirect_to(:action => :show, :name => 'diasporarocks!')
      end
    end

    context 'signed in' do
      before do
        sign_in :user, alice
      end

      it 'assigns a Stream::Tag object with the current_user' do
        get :show, :name => 'yes'
        assigns[:stream].user.should == alice
      end

      it 'succeeds' do
        get :show, :name => 'hellyes'
        response.status.should == 200
      end
    end

    context "not signed in" do
      it 'assigns a Stream::Tag object with no user' do
        get :show, :name => 'yes'
        assigns[:stream].user.should be_nil
      end

      it 'succeeds' do
        get :show, :name => 'hellyes'
        response.status.should == 200
      end

      it 'succeeds with mobile' do 
        get :show, :name => 'foo', :format => :mobile
        response.should be_success
      end
    end
  end

  context 'helper methods' do
    describe 'tag_followed?' do
      before do
        sign_in bob
        @tag = ActsAsTaggableOn::Tag.create!(:name => "partytimeexcellent")
        @controller.stub(:current_user).and_return(bob)
        @controller.stub(:params).and_return({:name => "PARTYTIMEexcellent"})
      end

      it 'returns true if the following already exists and should be case insensitive' do
        TagFollowing.create!(:tag => @tag, :user => bob )
        @controller.send(:tag_followed?).should be_true
      end

      it 'returns false if the following does not already exist' do
        @controller.send(:tag_followed?).should be_false
      end
    end
  end
end
