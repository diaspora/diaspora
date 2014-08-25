
require 'spec_helper'

describe Admin::UsersController, :type => :controller do
  before do
    @user = FactoryGirl.create :user
    Role.add_admin(@user.person)

    sign_in :user, @user
  end

  describe '#close_account' do
    it 'queues a job to disable the given account' do
      other_user = FactoryGirl.create :user
      expect(other_user).to receive(:close_account!)
      allow(User).to receive(:find).and_return(other_user)

      post :close_account, id: other_user.id
    end
  end

end
