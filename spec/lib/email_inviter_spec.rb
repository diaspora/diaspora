# frozen_string_literal: true

describe EmailInviter do
  before do
    @user = double(invitation_code: "coolcodebro", present?: true, email: "foo@bar.com")
    @emails = "mbs333@gmail.com, foo1@bar.com maxwell@dude.com"
  end

  it "has a list of emails" do
    inviter = EmailInviter.new(@emails, @user)
    expect(inviter.emails).not_to be_empty
  end

  it 'should parse three emails' do
    inviter = EmailInviter.new(@emails, @user)
    expect(inviter.emails.count).to eq(3)
  end

  it 'has an inviter' do
    inviter = EmailInviter.new(@emails, @user)
    expect(inviter.inviter).not_to be_nil
  end

  describe '#emails' do
    it 'rejects the inviter email if present' do
      inviter = EmailInviter.new(@emails + " #{@user.email}", @user)
      expect(inviter.emails).not_to include(@user.email)
    end
  end

  describe 'language' do
    it 'defaults to english' do
      inviter = EmailInviter.new(@emails, @user)
      expect(inviter.locale).to eq('en')
    end

    it 'should symbolize keys' do
      inviter = EmailInviter.new(@emails, @user, 'locale' => 'es')
      expect(inviter.locale).to eq('es')
    end

    it 'listens to the langauge option' do
      inviter = EmailInviter.new(@emails, @user, :locale => 'es')
      expect(inviter.locale).to eq('es')
    end
  end

  describe '#invitation_code' do
    it 'delegates to the user' do
      inviter = EmailInviter.new(@emails, @user)
      expect(inviter.invitation_code).to eq(@user.invitation_code)
    end
  end
end
