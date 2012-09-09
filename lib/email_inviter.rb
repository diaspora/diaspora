class EmailInviter
  attr_accessor :emails, :message, :inviter, :locale

  def initialize(emails, inviter, options={})
    self.message = options[:message]
    self.locale = options.fetch(:locale, 'en')
    self.inviter = inviter 
    self.emails = emails
  end

  def emails=(list)
    emails = list.split(%r{[,\s]+})
    emails.reject!{|x| x == inviter.email } unless inviter.nil?
    @emails = emails
  end

  def invitation_code
    @invitation_code ||= inviter.invitation_code 
  end

  def send!
    self.emails.each{ |email| mail(email)}
  end

  private

  def mail(email)
    Notifier.invite(email, message, inviter, invitation_code, locale).deliver!
  end
end
