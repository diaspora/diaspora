
require 'spec_helper'

describe Admin::UsersController do
  before do
    @user = FactoryGirl.create :user
    Role.add_admin(@user.person)

    sign_in :user, @user
  end

  describe '#close_account' do
    it 'queues a job to disable the given account' do
      other_user = FactoryGirl.create :user
      other_user.should_receive(:close_account!)
      User.stub(:find).and_return(other_user)

      post :close_account, id: other_user.id
    end
  end

end
