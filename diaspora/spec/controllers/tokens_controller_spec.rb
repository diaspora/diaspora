describe TokensController do
  describe '#show' do
    it 'succeeds' do
      sign_in eve
      get :show
      response.should be_success
    end
  end
end
