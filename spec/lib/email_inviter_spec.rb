require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'email_inviter')

describe EmailInviter do
  before do
    @user = stub(:invitation_code => 'coolcodebro', :present? => true, 
                 :email => 'foo@bar.com')
    @emails = "mbs333@gmail.com, foo1@bar.com maxwell@dude.com"
  end

  it 'has a list of emails' do 
    inviter = EmailInviter.new(@emails, @user)
    inviter.emails.should_not be_empty
  end

  it 'should parse three emails' do
    inviter = EmailInviter.new(@emails, @user)
    inviter.emails.count.should == 3
  end

  it 'has an inviter' do
    inviter = EmailInviter.new(@emails, @user)
    inviter.inviter.should_not be_nil
  end

  it 'can have a message' do
    message = "you guys suck hard"
    inviter = EmailInviter.new("emails", @user, :message =>  message)
    inviter.message.should == message 
  end

  describe '#emails' do
    it 'rejects the inviter email if present' do
      inviter = EmailInviter.new(@emails + " #{@user.email}", @user)
      inviter.emails.should_not include(@user.email)
    end
  end

  describe 'language' do
    it 'defaults to english' do
      inviter = EmailInviter.new(@emails, @user)
      inviter.locale.should == 'en'
    end

    it 'listens to the langauge option' do
      inviter = EmailInviter.new(@emails, @user, :locale => 'es')
      inviter.locale.should == 'es'
    end
  end

  describe '#invitation_code' do
    it 'delegates to the user' do
      inviter = EmailInviter.new(@emails, @user)
      inviter.invitation_code.should == @user.invitation_code
    end
  end
end