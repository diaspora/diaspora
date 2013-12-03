require 'spec_helper'

describe Users::PasswordController do
  before do
    sign_in :user, alice
    @controller.stub(:current_user).and_return( alice )
  end

  describe "#update" do
    let(:password_params) { { current_password: 'bluepin7',
                              password: 'foobaz',
                              password_confirmation: 'foobaz' } }
    let(:params) { { user: password_params } }

    it "uses devise's update with password" do
      alice.should_receive(:update_with_password).with( password_params.stringify_keys )
      put :update, params
    end

    it 'redirects to the login page' do
      put :update, params
      response.should redirect_to new_user_session_path
    end

    context 'on failure' do
      let(:params) { { user: {} } }

      it 'redirects to the user edit page' do
        put :update, params
        response.should redirect_to edit_user_path
      end
    end
  end
end
