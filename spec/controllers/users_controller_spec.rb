#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe UsersController do
  before do
    @user = alice
    sign_in :user, @user
    @controller.stub(:current_user).and_return(@user)
  end

  describe '#export' do
    it 'returns an xml file'  do
      get :export
      response.header["Content-Type"].should include "application/xml"
    end
  end

  describe '#export_photos' do
    it 'returns a tar file'  do
      get :export_photos
      response.header["Content-Type"].should include "application/octet-stream"
    end
  end

  describe 'user_photo' do
    it 'should return the url of the users profile photo' do
      get :user_photo, :username => @user.username
      response.should redirect_to(@user.profile.image_url)
    end

    it 'should 404 if no user is found' do
      get :user_photo, :username => 'none'
      response.should_not be_success
    end
  end

  describe '#public' do
    it 'renders xml if atom is requested' do
      sm = FactoryGirl.create(:status_message, :public => true, :author => @user.person)
      get :public, :username => @user.username, :format => :atom
      response.body.should include(sm.raw_message)
    end

    it 'renders xml if atom is requested with clickalbe urls' do
      sm = FactoryGirl.create(:status_message, :public => true, :author => @user.person)
      @user.person.posts.each do |p|
        p.text = "Goto http://diasporaproject.org/ now!"
        p.save
      end
      get :public, :username => @user.username, :format => :atom
      response.body.should include('a href')
    end

    it 'includes reshares in the atom feed' do
      reshare = FactoryGirl.create(:reshare, :author => @user.person)
      get :public, :username => @user.username, :format => :atom
      response.body.should include reshare.root.raw_message
    end

    it 'redirects to a profile page if html is requested' do
      get :public, :username => @user.username
      response.should be_redirect
    end

    it 'redirects to a profile page if mobile is requested' do
      get :public, :username => @user.username, :format => :mobile
      response.should be_redirect
    end
  end

  describe '#update' do
    before do
      @params  = { :id => @user.id,
                  :user => { :diaspora_handle => "notreal@stuff.com" } }
    end

    it "doesn't overwrite random attributes" do
      lambda {
        put :update, @params
      }.should_not change(@user, :diaspora_handle)
    end

    it 'redirects to the user edit page' do
      put :update, @params
      response.should redirect_to edit_user_path
    end

    it 'responds with a 204 on a js request' do
      put :update, @params.merge(:format => :js)
      response.status.should == 204
    end

    context 'password updates' do
      before do
        @password_params = {:current_password => 'bluepin7',
                            :password => "foobaz",
                            :password_confirmation => "foobaz"}
      end

      it "uses devise's update with password" do
        @user.should_receive(:update_with_password).with(hash_including(@password_params))
        @controller.stub!(:current_user).and_return(@user)
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
        @user.language.should_not == old_language
      end
    end

    describe 'email' do
      it 'disallow the user to change his new (unconfirmed) mail when it is the same as the old' do
        @user.email = "my@newemail.com"
        put(:update, :id => @user.id, :user => { :email => "my@newemail.com"})
        @user.reload
        @user.unconfirmed_email.should eql(nil)
      end

      it 'allow the user to change his (unconfirmed) email' do
        put(:update, :id => @user.id, :user => { :email => "my@newemail.com"})
        @user.reload
        @user.unconfirmed_email.should eql("my@newemail.com")
      end

      it 'informs the user about success' do
        put(:update, :id => @user.id, :user => { :email => "my@newemail.com"})
        request.flash[:notice].should eql(I18n.t('users.update.unconfirmed_email_changed'))
        request.flash[:error].should be_blank
      end

      it 'informs the user about failure' do
        put(:update, :id => @user.id, :user => { :email => "my@newemailcom"})
        request.flash[:error].should eql(I18n.t('users.update.unconfirmed_email_not_changed'))
        request.flash[:notice].should be_blank
      end

      it 'allow the user to change his (unconfirmed) email to blank (= abort confirmation)' do
        put(:update, :id => @user.id, :user => { :email => ""})
        @user.reload
        @user.unconfirmed_email.should eql(nil)
      end

      it 'sends out activation email on success' do
        Workers::Mail::ConfirmEmail.should_receive(:perform_async).with(@user.id).once
        put(:update, :id => @user.id, :user => { :email => "my@newemail.com"})
      end
    end

    describe 'email settings' do
      it 'lets the user turn off mail' do
        par = {:id => @user.id, :user => {:email_preferences => {'mentioned' => 'true'}}}
        proc{
          put :update, par
        }.should change(@user.user_preferences, :count).by(1)
      end

      it 'lets the user get mail again' do
        @user.user_preferences.create(:email_type => 'mentioned')
        par = {:id => @user.id, :user => {:email_preferences => {'mentioned' => 'false'}}}
        proc{
          put :update, par
        }.should change(@user.user_preferences, :count).by(-1)
      end
    end
  end

  describe '#privacy_settings' do
    it "returns a 200" do
      get 'privacy_settings'
      response.status.should == 200
    end
  end

  describe '#edit' do
    it "returns a 200" do
      get 'edit', :id => @user.id
      response.status.should == 200
    end

    it 'set @email_pref to false when there is a user pref' do
      @user.user_preferences.create(:email_type => 'mentioned')
      get 'edit', :id => @user.id
      assigns[:email_prefs]['mentioned'].should be_false
    end

    it 'does not allow token auth' do
      sign_out :user
      bob.reset_authentication_token!
      get :edit, :auth_token => bob.authentication_token
      response.should redirect_to new_user_session_path
    end
  end

  describe '#destroy' do
    it 'does nothing if the password does not match' do
      Workers::DeleteAccount.should_not_receive(:perform_async)
      delete :destroy, :user => { :current_password => "stuff" }
    end

    it 'closes the account' do
      alice.should_receive(:close_account!)
      delete :destroy, :user => { :current_password => "bluepin7" }
    end

    it 'enqueues a delete job' do
      Workers::DeleteAccount.should_receive(:perform_async).with(anything)
      delete :destroy, :user => { :current_password => "bluepin7" }
    end
  end

  describe '#confirm_email' do
    before do
      @user.update_attribute(:unconfirmed_email, 'my@newemail.com')
    end

    it 'redirects to to the user edit page' do
      get 'confirm_email', :token => @user.confirm_email_token
      response.should redirect_to edit_user_path
    end

    it 'confirms email' do
      get 'confirm_email', :token => @user.confirm_email_token
      @user.reload
      @user.email.should eql('my@newemail.com')
      request.flash[:notice].should eql(I18n.t('users.confirm_email.email_confirmed', :email => 'my@newemail.com'))
      request.flash[:error].should be_blank
    end

    it 'does NOT confirm email with wrong token' do
      get 'confirm_email', :token => @user.confirm_email_token.reverse
      @user.reload
      @user.email.should_not eql('my@newemail.com')
      request.flash[:error].should eql(I18n.t('users.confirm_email.email_not_confirmed'))
      request.flash[:notice].should be_blank
    end
  end

  describe 'getting_started' do
    it 'does not fail miserably' do
      get :getting_started
      response.should be_success
    end

    it 'does not fail miserably on mobile' do
      get :getting_started, :format => :mobile
      response.should be_success
    end
  end
end
