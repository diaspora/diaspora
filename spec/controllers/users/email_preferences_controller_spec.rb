require 'spec_helper'

describe Users::EmailPreferencesController do
  before do
    @user = alice
    sign_in :user, @user
    @controller.stub(:current_user).and_return(@user)
  end

  describe "#update" do
    it 'redirects to the user edit page' do
      put :update, { user: { email_preferences: { 'mentioned' => 'true' } } }
      response.should redirect_to edit_user_path
    end

    # This test and the next are pretty opaque imo
    # Just moving them as is from users_controller_spec as part of the refactor
    it 'lets the user turn off mail' do
      params = {:id => @user.id, :user => {:email_preferences => {'mentioned' => 'true'}}}
      proc{
        put :update, params
      }.should change(@user.user_preferences, :count).by(1)
    end

    it 'lets the user get mail again' do
      @user.user_preferences.create(:email_type => 'mentioned')
      params = {:id => @user.id, :user => {:email_preferences => {'mentioned' => 'false'}}}
      proc{
        put :update, params
      }.should change(@user.user_preferences, :count).by(-1)
    end
  end

end
