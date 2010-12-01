require 'test/test_helper'

class InvitationMailTest < ActionMailer::TestCase

  def setup
    setup_mailer
    Devise.mailer_sender = 'test@example.com'
  end

  def user
    @user ||= begin
      user = create_user_with_invitation('token')
      user.send_invitation
      user
    end
  end

  def mail
    @mail ||= begin
      user
      ActionMailer::Base.deliveries.last
    end
  end

  test 'email sent after reseting the user password' do
    assert_not_nil mail
  end

  test 'content type should be set to html' do
    assert_equal 'text/html; charset=UTF-8', mail.content_type
  end

  test 'send invitation to the user email' do
    assert_equal [user.email], mail.to
  end

  test 'setup sender from configuration' do
    assert_equal ['test@example.com'], mail.from
  end

  test 'setup subject from I18n' do
    store_translations :en, :devise => { :mailer => { :invitation => { :subject => 'Localized Invitation' } } } do
      assert_equal 'Localized Invitation', mail.subject
    end
  end

  test 'subject namespaced by model' do
    store_translations :en, :devise => { :mailer => { :invitation => { :user_subject => 'User Invitation' } } } do
      assert_equal 'User Invitation', mail.subject
    end
  end

  test 'body should have user info' do
    assert_match /#{user.email}/, mail.body
  end

  test 'body should have link to confirm the account' do
    host = ActionMailer::Base.default_url_options[:host]
    invitation_url_regexp = %r{<a href=\"http://#{host}/users/invitation/accept\?invitation_token=#{user.invitation_token}">}
    assert_match invitation_url_regexp, mail.body
  end
end
