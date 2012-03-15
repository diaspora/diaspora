require 'spec_helper'

describe InvitationCode do
  it 'has a valid factory' do
    Factory(:invitation_code).should be_valid
  end

  it 'sets the count to a default value' do
    code = Factory(:invitation_code)
    code.count.should > 0 
  end

  describe '#use!' do
    it 'decrements the count of the code' do
      code = Factory(:invitation_code)

      expect{
        code.use!
      }.to change(code, :count).by(-1)
    end
  end

  describe '.default_inviter_or' do
    before do
      @old_account = AppConfig[:admin_account]
      AppConfig[:admin_account] = 'bob'
    end

    after do
      AppConfig[:admin_account] = @old_account
    end

    it 'grabs the set admin account for the pod...' do
      InvitationCode.default_inviter_or(alice).username.should == 'bob'
    end

    it '..or the given user' do
      AppConfig[:admin_account] = ''
      InvitationCode.default_inviter_or(alice).username.should == 'alice'
    end
  end
end
