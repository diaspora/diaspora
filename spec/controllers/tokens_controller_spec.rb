describe TokensController do
  before do
    AppConfig[:admins] = [bob.username]
    AppConfig[:auth_tokenable] = [eve.username]
  end
  describe '#create' do
    it 'generates a new token for the current user' do
      sign_in bob
      lambda {
        get :create
      }.should change{ bob.reload.authentication_token }
    end
    it 'redirects normal users away' do
      sign_in alice
      get :create
      response.should redirect_to root_url
    end
  end
  describe '#edit' do
    it 'displays a token' do
      sign_in bob
      get :create
      get :show
      response.body.should include(bob.reload.authentication_token)
    end
  end
end
