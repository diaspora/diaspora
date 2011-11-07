#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ServicesController do
  let(:mock_access_token) { Object.new }

  let(:omniauth_auth) {
    { 'provider' => 'twitter',
      'uid'      => '2',
      'user_info'   => { 'nickname' => 'grimmin' },
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
        Factory(:service, :user => @user)
      end

      get :index
      assigns[:services].should == @user.services
    end
  end

  describe '#create' do
    it 'creates a new OmniauthService' do
      request.env['omniauth.auth'] = omniauth_auth
      lambda{
        post :create, :provider => 'twitter'
      }.should change(@user.services, :count).by(1)
    end

    it 'redirects to getting started if the user is getting started' do
      @user.getting_started = true
      request.env['omniauth.auth'] = omniauth_auth
      post :create, :provider => 'twitter'
      response.should redirect_to getting_started_path
    end

    it 'redirects to services url' do
      @user.getting_started = false
      request.env['omniauth.auth'] = omniauth_auth
      post :create, :provider => 'twitter'
      response.should redirect_to services_url
    end

    it 'creates a twitter service' do
      Service.delete_all
      @user.getting_started = false
      request.env['omniauth.auth'] = omniauth_auth
      post :create, :provider => 'twitter'
      @user.reload.services.first.class.name.should == "Services::Twitter"
    end

    it 'returns error if the service is connected with that uid' do
      request.env['omniauth.auth'] = omniauth_auth

      Services::Twitter.create!(:nickname => omniauth_auth["user_info"]['nickname'],
                                           :access_token => omniauth_auth['credentials']['token'],
                                           :access_secret => omniauth_auth['credentials']['secret'],
                                           :uid => omniauth_auth['uid'],
                                           :user => bob)

      post :create, :provider => 'twitter'

      flash[:error].include?(bob.person.profile.diaspora_handle).should be_true
    end

    context "photo fetching" do
      before do
        omniauth_auth
        omniauth_auth["user_info"].merge!({"image" => "https://service.com/fallback_lowres.jpg"})

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
      @service1 = Factory.create(:service, :user => @user)
    end

    it 'destroys a service selected by id' do
      lambda{
        delete :destroy, :id => @service1.id
      }.should change(@user.services, :count).by(-1)
    end
  end

  describe '#finder' do
    before do
      @service1 = Services::Facebook.new
      @user.services << @service1
      @person = Factory(:person)
      @user.services.stub!(:where).and_return([@service1])
      @service_users = [ ServiceUser.create(:contact => @user.contact_for(bob.person), :name => "Robert Bobson", :photo_url => "cdn1.fb.com/pic1.jpg",
                                  :service => @service1, :uid => "321" ).tap{|su| su.stub!(:person).and_return(bob.person)},
                ServiceUser.create(:name => "Eve Doe", :photo_url => "cdn1.fb.com/pic1.jpg", :person => eve.person, :service => @service1,
                                   :uid => 'sdfae').tap{|su| su.stub!(:person).and_return(eve.person)},
                ServiceUser.create(:name => "Robert Bobson", :photo_url => "cdn1.fb.com/pic1.jpg", :service => @service1, :uid => "dsfasdfas")]
      @service1.should_receive(:finder).and_return(@service_users)
    end

    it 'calls the finder method for the service for that user' do
      get :finder, :provider => @service1.provider
      response.should be_success
    end

    it 'has no translations missing' do
      get :finder, :provider => @service1.provider
      Nokogiri(response.body).css('.translation_missing').should be_empty
    end
  end

  describe '#inviter' do
    before do
      @uid = "abc"
      fb = Factory(:service, :type => "Services::Facebook", :user => @user)
      fb = Services::Facebook.find(fb.id)
      @su = Factory(:service_user, :service => fb, :uid => @uid)
      @invite_params = {:provider => 'facebook', :uid => @uid, :aspect_id => @user.aspects.first.id}
    end

    it 'redirects to a prefilled facebook message url' do
      put :inviter, @invite_params
      response.location.should match(/https:\/\/www\.facebook\.com\/\?compose=1&id=.*&subject=.*&message=.*&sk=messages/)
    end

    it 'creates an invitation' do
      lambda {
        put :inviter, @invite_params
      }.should change(Invitation, :count).by(1)
    end

    it 'sets the invitation_id on the service_user' do
      post :inviter, @invite_params
      @su.reload.invitation.should_not be_nil
    end

    it 'does not create a duplicate invitation' do
      invited_user = Factory.build(:user, :username =>nil)
      invited_user.save(:validate => false)
      inv = Invitation.create!(:sender => @user, :recipient => invited_user, :aspect => @user.aspects.first, :identifier => eve.email)
      @invite_params[:invitation_id] = inv.id

      lambda {
        put :inviter, @invite_params
      }.should_not change(Invitation, :count)
    end

    it 'disregards the amount of invites if open_invitations are enabled' do
      open_bit = AppConfig[:open_invitations]
      AppConfig[:open_invitations] = true

      lambda {
        put :inviter, @invite_params
      }.should change(Invitation, :count).by(1)
      AppConfig[:open_invitations] = open_bit
    end
  end
end
