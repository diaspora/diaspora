require File.dirname(__FILE__) + '/../spec_helper'
 
describe UsersController do
  before do
    #TODO(dan) Mocking Warden; this is a temp fix
    request.env['warden'] = mock_model(Warden, :authenticate => @user, :authenticate! => @user)
  end
  render_views
  #fixtures :all
  
  it 'should, after logging in redirect to the dashboard page' do
    pending
    #go to /login
    #fill in the form
    #stub create action
    #should get a redirect
  end
end
