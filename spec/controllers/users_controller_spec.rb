#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe UsersController, :type => :controller do
  before do
    @user = alice
    sign_in :user, @user
    allow(@controller).to receive(:current_user).and_return(@user)
  end

  describe '#export' do
    it 'returns an xml file'  do
      get :export
      expect(response.header["Content-Type"]).to include "application/xml"
    end
  end

  describe '#export_photos' do
    it 'returns a tar file'  do
      get :export_photos
      expect(response.header["Content-Type"]).to include "application/octet-stream"
    end
  end

  describe 'user_photo' do
    it 'should return the url of the users profile photo' do
      get :user_photo, :username => @user.username
      expect(response).to redirect_to(@user.profile.image_url)
    end

    it 'should 404 if no user is found' do
      get :user_photo, :username => 'none'
      expect(response).not_to be_success
    end
  end

  describe '#public' do
    it 'renders xml if atom is requested' do
      sm = FactoryGirl.create(:status_message, :public => true, :author => @user.person)
      get :public, :username => @user.username, :format => :atom
      expect(response.body).to include(sm.raw_message)
    end

    it 'renders xml if atom is requested with clickalbe urls' do
      sm = FactoryGirl.create(:status_message, :public => true, :author => @user.person)
      @user.person.posts.each do |p|
        p.text = "Goto http://diasporaproject.org/ now!"
        p.save
      end
      get :public, :username => @user.username, :format => :atom
      expect(response.body).to include('a href')
    end
    
    it 'includes reshares in the atom feed' do
      reshare = FactoryGirl.create(:reshare, :author => @user.person)
      get :public, :username => @user.username, :format => :atom
      expect(response.body).to include reshare.root.raw_message
    end

    it 'do not show reshares in atom feed if origin post is deleted' do
      post = FactoryGirl.create(:status_message, :public => true);
      reshare = FactoryGirl.create(:reshare, :root => post, :author => @user.person)
      post.delete
      get :public, :username => @user.username, :format => :atom
      expect(response.code).to eq('200')
    end

    it 'redirects to a profile page if html is requested' do
      get :public, :username => @user.username
      expect(response).to be_redirect
    end

    it 'redirects to a profile page if mobile is requested' do
      get :public, :username => @user.username, :format => :mobile
      expect(response).to be_redirect
    end
  end

  describe '#update' do
    before do
      @params  = { :id => @user.id,
                  :user => { :diaspora_handle => "notreal@stuff.com" } }
    end

    it "doesn't overwrite random attributes" do
      expect {
        put :update, @params
      }.not_to change(@user, :diaspora_handle)
    end

    it 'redirects to the user edit page' do
      put :update, @params
      expect(response).to redirect_to edit_user_path
    end

    it 'responds with a 204 on a js request' do
      put :update, @params.merge(:format => :js)
      expect(response.status).to eq(204)
    end

    context 'password updates' do
      before do
        @password_params = {:current_password => 'bluepin7',
                            :password => "foobaz",
                            :password_confirmation => "foobaz"}
      end

      it "uses devise's update with password" do
        expect(@user).to receive(:update_with_password).with(hash_including(@password_params))
        allow(@controller).to receive(:current_user).and_return(@user)
        put :update, :id => @user.id, :user => @password_params
      end
    end

    describe 'language' do
      it 'allow the user to change his language' do
        old_language = 'en'
        @user.language = old_language
        @user.save
        put(:update, :id => @user.id, :user =>
            { :language => "fr"}
           )
        @user.reload
        expect(@user.language).not_to eq(old_language)
      end
    end

    describe 'email' do
      it 'disallow the user to change his new (unconfirmed) mail when it is the same as the old' do
        @user.email = "my@newemail.com"
        put(:update, :id => @user.id, :user => { :email => "my@newemail.com"})
        @user.reload
        expect(@user.unconfirmed_email).to eql(nil)
      end

      it 'allow the user to change his (unconfirmed) email' do
        put(:update, :id => @user.id, :user => { :email => "my@newemail.com"})
        @user.reload
        expect(@user.unconfirmed_email).to eql("my@newemail.com")
      end

      it 'informs the user about success' do
        put(:update, :id => @user.id, :user => { :email => "my@newemail.com"})
        expect(request.flash[:notice]).to eql(I18n.t('users.update.unconfirmed_email_changed'))
        expect(request.flash[:error]).to be_blank
      end

      it 'informs the user about failure' do
        put(:update, :id => @user.id, :user => { :email => "my@newemailcom"})
        expect(request.flash[:error]).to eql(I18n.t('users.update.unconfirmed_email_not_changed'))
        expect(request.flash[:notice]).to be_blank
      end

      it 'allow the user to change his (unconfirmed) email to blank (= abort confirmation)' do
        put(:update, :id => @user.id, :user => { :email => ""})
        @user.reload
        expect(@user.unconfirmed_email).to eql(nil)
      end

      it 'sends out activation email on success' do
        expect(Workers::Mail::ConfirmEmail).to receive(:perform_async).with(@user.id).once
        put(:update, :id => @user.id, :user => { :email => "my@newemail.com"})
      end
    end

    describe 'email settings' do
      it 'lets the user turn off mail' do
        par = {:id => @user.id, :user => {:email_preferences => {'mentioned' => 'true'}}}
        expect{
          put :update, par
        }.to change(@user.user_preferences, :count).by(1)
      end

      it 'lets the user get mail again' do
        @user.user_preferences.create(:email_type => 'mentioned')
        par = {:id => @user.id, :user => {:email_preferences => {'mentioned' => 'false'}}}
        expect{
          put :update, par
        }.to change(@user.user_preferences, :count).by(-1)
      end
    end

    describe 'getting started' do
      it 'can be reenabled' do
        put :update, user: {getting_started: true}
        expect(@user.reload.getting_started?).to be true
      end
    end
  end

  describe '#privacy_settings' do
    it "returns a 200" do
      get 'privacy_settings'
      expect(response.status).to eq(200)
    end
  end

  describe '#edit' do
    it "returns a 200" do
      get 'edit', :id => @user.id
      expect(response.status).to eq(200)
    end

    it 'set @email_pref to false when there is a user pref' do
      @user.user_preferences.create(:email_type => 'mentioned')
      get 'edit', :id => @user.id
      expect(assigns[:email_prefs]['mentioned']).to be false
    end

    it 'does not allow token auth' do
      sign_out :user
      bob.reset_authentication_token!
      get :edit, :auth_token => bob.authentication_token
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe '#destroy' do
    it 'does nothing if the password does not match' do
      expect(Workers::DeleteAccount).not_to receive(:perform_async)
      delete :destroy, :user => { :current_password => "stuff" }
    end

    it 'closes the account' do
      expect(alice).to receive(:close_account!)
      delete :destroy, :user => { :current_password => "bluepin7" }
    end

    it 'enqueues a delete job' do
      expect(Workers::DeleteAccount).to receive(:perform_async).with(anything)
      delete :destroy, :user => { :current_password => "bluepin7" }
    end
  end

  describe '#confirm_email' do
    before do
      @user.update_attribute(:unconfirmed_email, 'my@newemail.com')
    end

    it 'redirects to to the user edit page' do
      get 'confirm_email', :token => @user.confirm_email_token
      expect(response).to redirect_to edit_user_path
    end

    it 'confirms email' do
      get 'confirm_email', :token => @user.confirm_email_token
      @user.reload
      expect(@user.email).to eql('my@newemail.com')
      expect(request.flash[:notice]).to eql(I18n.t('users.confirm_email.email_confirmed', :email => 'my@newemail.com'))
      expect(request.flash[:error]).to be_blank
    end

    it 'does NOT confirm email with wrong token' do
      get 'confirm_email', :token => @user.confirm_email_token.reverse
      @user.reload
      expect(@user.email).not_to eql('my@newemail.com')
      expect(request.flash[:error]).to eql(I18n.t('users.confirm_email.email_not_confirmed'))
      expect(request.flash[:notice]).to be_blank
    end
  end

  describe 'getting_started' do
    it 'does not fail miserably' do
      get :getting_started
      expect(response).to be_success
    end

    it 'does not fail miserably on mobile' do
      get :getting_started, :format => :mobile
      expect(response).to be_success
    end
  end
end
