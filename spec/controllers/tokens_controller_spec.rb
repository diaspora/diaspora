describe TokensController do
  describe '#create' do
    it 'generates a new token for the current user' do
      sign_in bob
      lambda {
        get :create
      }.should change{ bob.reload.authentication_token }
    end
  end
  describe '#edit' do
    it 'displays a token' do
      sign_in eve
      get :create
      get :show
      response.body.should include(eve.reload.authentication_token)
    end
  end
end
