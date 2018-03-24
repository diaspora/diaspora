# frozen_string_literal: true

describe InvitationCode, :type => :model do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:invitation_code)).to be_valid
  end

  it 'sets the count to a default value' do
    code = FactoryGirl.create(:invitation_code)
    expect(code.count).to be > 0
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
    it 'grabs the set admin account for the pod...' do
      AppConfig.admins.account = 'bob'
      expect(InvitationCode.default_inviter_or(alice).username).to eq('bob')
    end

    it '..or the given user' do
      AppConfig.admins.account = ''
      expect(InvitationCode.default_inviter_or(alice).username).to eq('alice')
    end
  end
end
