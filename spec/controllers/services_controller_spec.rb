# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ServicesController, :type => :controller do
  let(:omniauth_auth) do
    { 'provider' => 'facebook',
      'uid'      => '2',
      'info'   => { 'nickname' => 'grimmin', 'image' => 'http://graph.facebook.com/2/picture' },
      'credentials' => { 'token' => 'tokin', 'secret' =>"not_so_much" }}
    end
  let(:user) { alice }

  before do
    sign_in user, scope: :user
    allow(@controller).to receive(:current_user).and_return(user)
  end

  describe '#index' do
    before do
      FactoryGirl.create(:service, user: user)
    end

    it "displays user's connected services" do
      get :index
      expect(assigns[:services]).to eq(user.services)
    end
  end

  describe '#create' do
    before do
      request.env['omniauth.auth'] = omniauth_auth
      request.env['omniauth.origin'] = root_url
    end

    it 'creates a new service and associates it with the current user' do
      expect {
        post :create, params: {provider: "facebook"}
      }.to change(user.services, :count).by(1)
    end

    it 'saves the provider' do
      post :create, params: {provider: "facebook"}
      expect(user.reload.services.first.class.name).to eq("Services::Facebook")
    end

    context "when the user hasn't got a profile photo on Diaspora" do
      before { user.person.profile.update_attribute :image_url, nil }

      it "imports the profile photo from the service" do
        expect(Workers::FetchProfilePhoto).to receive(:perform_async)
        post :create, params: {provider: "facebook"}
      end
    end

    context 'when service exists with the same uid' do
      before { Services::Twitter.create!(uid: omniauth_auth['uid'], user_id: user.id) }

      it 'doesnt create a new service' do
        service_count = Service.count
        post :create, params: {provider: "twitter"}
        expect(Service.count).to eq(service_count)
      end

      it 'flashes an already_authorized error with the diaspora handle for the user'  do
        post :create, params: {provider: "twitter"}
        expect(flash[:error].include?(user.profile.diaspora_handle)).to be true
        expect(flash[:error].include?( 'already authorized' )).to be true
      end
    end

    context 'Twitter' do
      context 'when the access-level is read-only' do

        let(:header) { { 'x-access-level' => 'read' } }
        let(:access_token) { double("access_token") }
        let(:extra) { {'extra' => { 'access_token' => access_token }} }
        let(:provider) { {'provider' => 'twitter'} }

        before do
          allow(access_token).to receive_message_chain(:response, :header).and_return header
          request.env['omniauth.auth'] = omniauth_auth.merge!( provider).merge!( extra )
        end

        it 'doesnt create a new service' do
          service_count = Service.count
          post :create, params: {provider: "twitter"}
          expect(Service.count).to eq(service_count)
        end

        it 'flashes an read-only access error'  do
          post :create, params: {provider: "twitter"}
          expect(flash[:error].include?( 'Access level is read-only' )).to be true
        end
      end
    end

    context 'Facebook' do
      before do
        facebook_auth_without_twitter_extras = { 'provider' => 'facebook', 'extras' => { 'someotherkey' => 'lorem'}}
        request.env['omniauth.auth'] = omniauth_auth.merge!( facebook_auth_without_twitter_extras )
      end

      it "doesn't break when twitter-specific extras aren't available in omniauth hash" do
        expect {
          post :create, params: {provider: "facebook"}
        }.to change(user.services, :count).by(1)
      end
    end

    context 'when fetching a photo' do
      before do
        omniauth_auth
        omniauth_auth["info"].merge!({"image" => "https://service.com/fallback_lowres.jpg"})

        request.env['omniauth.auth'] = omniauth_auth
      end

      it 'does not queue a job if the profile photo is set' do
        allow(@controller).to receive(:no_profile_image?).and_return false

        expect(Workers::FetchProfilePhoto).not_to receive(:perform_async)

        post :create, params: {provider: "twitter"}
      end

      it 'queues a job to save user photo if the photo does not exist' do
        allow(@controller).to receive(:no_profile_image?).and_return true

        expect(Workers::FetchProfilePhoto).to receive(:perform_async).with(user.id, anything(), "https://service.com/fallback_lowres.jpg")

        post :create, params: {provider: "twitter"}
      end
    end
  end

  describe '#destroy' do
    before do
      @service1 = FactoryGirl.create(:service, :user => user)
    end

    it 'destroys a service selected by id' do
      expect{
        delete :destroy, params: {id: @service1.id}
      }.to change(user.services, :count).by(-1)
    end
  end
end
