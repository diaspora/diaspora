#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ServicesController do
  let(:mock_access_token) { Object.new }

  let(:omniauth_auth) {
    { 'provider' => 'twitter',
      'uid'      => '2',
      'info'   => { 'nickname' => 'grimmin' },
      'credentials' => { 'token' => 'tokin', 'secret' =>"not_so_much" }
      }
  }

  before do
    @user   = alice
    @aspect = @user.aspects.first

    sign_in :user, @user
    @controller.stub!(:current_user).and_return(@user)
    mock_access_token.stub!(:token => "12345", :secret => "56789")
  end

  describe '#index' do
    it 'displays all connected serivices for a user' do
      4.times do
        FactoryGirl.create(:service, :user => @user)
      end

      get :index
      assigns[:services].should == @user.services
    end
  end

  describe '#create' do
    context 'when not fetching a photo' do
      before do
        request.env['omniauth.auth'] = omniauth_auth
      end

      it 'creates a new OmniauthService' do
        expect {
          post :create, :provider => 'twitter'
        }.to change(@user.services, :count).by(1)
      end

      it 'creates a twitter service' do
        Service.delete_all
        @user.getting_started = false
        post :create, :provider => 'twitter'
        @user.reload.services.first.class.name.should == "Services::Twitter"
      end

      it 'returns error if the user already a service with that uid' do
        Services::Twitter.create!(:nickname => omniauth_auth["info"]['nickname'],
                                  :access_token => omniauth_auth['credentials']['token'],
                                  :access_secret => omniauth_auth['credentials']['secret'],
                                  :uid => omniauth_auth['uid'],
                                  :user => bob)
        post :create, :provider => 'twitter'
        flash[:error].include?(bob.person.profile.diaspora_handle).should be_true
      end
    end

    context 'when fetching a photo' do
      before do
        omniauth_auth
        omniauth_auth["info"].merge!({"image" => "https://service.com/fallback_lowres.jpg"})

        request.env['omniauth.auth'] = omniauth_auth
      end

      it 'does not queue a job if the profile photo is set' do
        profile = @user.person.profile
        profile[:image_url] = "/non/default/image.jpg"
        profile.save

        Resque.should_not_receive(:enqueue)

        post :create, :provider => 'twitter'
      end

      it 'queues a job to save user photo if the photo does not exist' do
        profile = @user.person.profile
        profile[:image_url] = nil
        profile.save

        Resque.should_receive(:enqueue).with(Jobs::FetchProfilePhoto, @user.id, anything(), "https://service.com/fallback_lowres.jpg")

        post :create, :provider => 'twitter'
      end
    end
  end

  describe '#destroy' do
    before do
      @service1 = FactoryGirl.create(:service, :user => @user)
    end

    it 'destroys a service selected by id' do
      lambda{
        delete :destroy, :id => @service1.id
      }.should change(@user.services, :count).by(-1)
    end
  end

end
