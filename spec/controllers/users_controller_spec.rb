require File.dirname(__FILE__) + '/../spec_helper'
 
describe UsersController do
  before do
    #TODO(dan) Mocking Warden; this is a temp fix
    request.env['warden'] = mock_model(Warden, :authenticate => @user, :authenticate! => @user)
  end
  render_views
  #fixtures :all
end  
describe Devise::SessionsController do
  before do
    #TODO(dan) Mocking Warden; this is a temp fix
    request.env['warden'] = mock_model(Warden, :authenticate => @user, :authenticate! => @user)
    @user = User.create(:email => "bob@rob.com", :password => "lala")
  end
    it 'should, after logging in redirect to the dashboard page' do
      pending "probs should be in cucumber"
      sign_in :user, @user
      # request.env['warden'].should_receive(:authenticated?).at_least(:once)
      # request.env['warden'].should_receive(:user).at_least(:once)
      
      #User.any_instance.stubs(:valid?).returns(true)
      #post :create

    end
  end

