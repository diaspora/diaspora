#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ServicesController do
  render_views
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
    @user.invites = 100
    @user.save

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
      response.should redirect_to getting_started_path(:step => 3)
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
      @hash = [ ServiceUser.create(:contact => @user.contact_for(bob.person), :name => "Robert Bobson", :photo_url => "cdn1.fb.com/pic1.jpg", :person => bob.person,
                                  :service => @service1, :uid => "321" ),
                ServiceUser.create(:name => "Robert Bobson", :photo_url => "cdn1.fb.com/pic1.jpg", :service => @service1, :uid => "dsfasdfas")]
      @service1.should_receive(:finder).and_return(@hash)
    end

    it 'calls the finder method for the service for that user' do
      get :finder, :provider => @service1.provider
      response.should be_success
    end
    it 'has no translations missing' do
      get :finder, :provider => @service1.provider
      response.body.match(/translation/).should be_nil
    end
  end

  describe '#invite' do

    before do
      @uid = "abc"
      @invite_params = {:provider => 'facebook', :uid => @uid, :aspect_id => @user.aspects.first.id}
    end

    it 'sets the subject' do
      put :inviter, @invite_params
      assigns[:subject].should_not be_nil
    end

    it 'sets a message containing the invitation link' do
      put :inviter, @invite_params
      assigns[:message].should include(User.last.invitation_token)
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

    it 'does not create a duplicate invitation' do
      inv = Invitation.create!(:sender_id => @user.id, :recipient_id => eve.id, :aspect_id => @user.aspects.first.id)
      @invite_params[:invitation_id] = inv.id

      lambda {
        put :inviter, @invite_params
      }.should_not change(Invitation, :count)
    end
  end
end

