# frozen_string_literal: true

describe Admin::UsersController, :type => :controller do
  before do
    @user = FactoryGirl.create :user
    Role.add_admin(@user.person)

    sign_in @user, scope: :user
  end

  describe '#close_account' do
    it 'queues a job to disable the given account' do
      other_user = FactoryGirl.create :user
      expect(other_user).to receive(:close_account!)
      allow(User).to receive(:find).and_return(other_user)

      post :close_account, params: {id: other_user.id}
    end
  end

  describe '#lock_account' do
    it 'it locks the given account' do
      other_user = FactoryGirl.create :user
      other_user.lock_access!
      expect(other_user.reload.access_locked?).to be_truthy
    end
  end

  describe '#unlock_account' do
    it 'it unlocks the given account' do
      other_user = FactoryGirl.create :user
      other_user.lock_access!
      other_user.unlock_access!
      expect(other_user.reload.access_locked?).to be_falsey
    end
  end

end
