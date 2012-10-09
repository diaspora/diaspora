require 'spec_helper'

describe InvitationCode do
  it 'has a valid factory' do
    FactoryGirl.build(:invitation_code).should be_valid
  end

  it 'sets the count to a default value' do
    code = FactoryGirl.create(:invitation_code)
    code.count.should > 0 
  end

  describe '#use!' do
    it 'decrements the count of the code' do
      code = FactoryGirl.create(:invitation_code)

      expect{
        code.use!
      }.to change(code, :count).by(-1)
    end
  end

  describe '.default_inviter_or' do
    before do
      @old_account = AppConfig.admins.account.get
      AppConfig.admins.account = 'bob'
    end

    after do
      AppConfig.admins.account = @old_account
    end

    it 'grabs the set admin account for the pod...' do
      InvitationCode.default_inviter_or(alice).username.should == 'bob'
    end

    it '..or the given user' do
      AppConfig.admins.account = ''
      InvitationCode.default_inviter_or(alice).username.should == 'alice'
    end
  end
end
