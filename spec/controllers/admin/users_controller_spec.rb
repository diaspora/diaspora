
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

  describe '#lock_account' do
    it 'it locks the given account' do
      other_user = FactoryGirl.create :user
      other_user.lock_access!
      expect(other_user.reload.access_locked?).to be_truthy
      expect(other_user.lock_expires).to be_falsey
    end

    it "it locks the given account for a certain amount of time" do
      other_user = FactoryGirl.create :user
      current_time = Time.now.utc
      other_user.lock_access!(unlock_in: 10.minutes)
      expect((other_user.locked_at - current_time).to_i).to eq(600)
      expect(other_user.lock_expires).to be_truthy
    end

    it "it should expire with unlock_in set only" do
      other_user = FactoryGirl.create :user
      other_user.lock_access!(unlock_in: 10.minutes)
      expect(other_user.lock_expires).to be_truthy
      other_user.unlock_access!
      expect(other_user.lock_expires).to be_falsey
      other_user.lock_access!
      expect(other_user.lock_expires).to be_falsey
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
