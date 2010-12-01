class ActiveSupport::TestCase
  def setup_mailer
    ActionMailer::Base.deliveries = []
  end

  def store_translations(locale, translations, &block)
    begin
      I18n.backend.store_translations locale, translations
      yield
    ensure
      I18n.reload!
    end
  end

  # Helpers for creating new users
  #
  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@email.com"
  end

  def valid_attributes(attributes={})
    { :email => generate_unique_email,
      :password => '123456',
      :password_confirmation => '123456' }.update(attributes)
  end

  def new_user(attributes={})
    User.new(valid_attributes(attributes))
  end

  def create_user_with_invitation(invitation_token, attributes={})
    user = new_user({:password => nil, :password_confirmation => nil}.update(attributes))
    user.skip_confirmation!
    user.invitation_token = invitation_token
    user.invitation_sent_at = Time.now.utc
    user.save(:validate => false)
    user
  end
end
