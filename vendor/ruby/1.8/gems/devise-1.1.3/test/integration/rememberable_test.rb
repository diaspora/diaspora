require 'test_helper'

class RememberMeTest < ActionController::IntegrationTest

  def create_user_and_remember(add_to_token='')
    user = create_user
    user.remember_me!
    raw_cookie = User.serialize_into_cookie(user).tap { |a| a.last << add_to_token }
    cookies['remember_user_token'] = generate_signed_cookie(raw_cookie)
    user
  end

  def generate_signed_cookie(raw_cookie)
    request = ActionDispatch::TestRequest.new
    request.cookie_jar.signed['raw_cookie'] = raw_cookie
    request.cookie_jar['raw_cookie']
  end

  def signed_cookie(key)
    controller.send(:cookies).signed[key]
  end

  def cookie_expires(key)
    cookie = response.headers["Set-Cookie"].split("\n").grep(/^#{key}/).first
    cookie.split(";").map(&:strip).grep(/^expires=/)
    Time.parse($')
  end

  test 'do not remember the user if he has not checked remember me option' do
    user = sign_in_as_user
    assert_nil request.cookies["remember_user_cookie"]
    assert_nil user.reload.remember_token
  end

  test 'generate remember token after sign in' do
    user = sign_in_as_user :remember_me => true
    assert request.cookies["remember_user_token"]
    assert user.reload.remember_token
  end

  test 'generate remember token after sign in setting cookie domain' do
    # We test this by asserting the cookie is not sent after the redirect
    # since we changed the domain. This is the only difference with the
    # previous test.
    swap User, :cookie_domain => "omg.somewhere.com" do
      user = sign_in_as_user :remember_me => true
      assert_nil request.cookies["remember_user_token"]
    end
  end

  test 'remember the user before sign in' do
    user = create_user_and_remember
    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
    assert warden.user(:user) == user
  end

  test 'does not extend remember period through sign in' do
    swap Devise, :extend_remember_period => true, :remember_for => 1.year do
      user = create_user
      user.remember_me!

      user.remember_created_at = old = 10.days.ago
      user.save

      sign_in_as_user :remember_me => true
      user.reload

      assert warden.user(:user) == user
      assert_equal old.to_i, user.remember_created_at.to_i
    end
  end

  test 'if both extend_remember_period and remember_across_browsers are true, sends the same token with a new expire date' do
    swap Devise, :remember_across_browsers => true, :extend_remember_period => true, :remember_for => 1.year do
      user  = create_user_and_remember
      token = user.remember_token

      user.remember_created_at = old = 10.minutes.ago
      user.save!

      get users_path
      assert (cookie_expires("remember_user_token") - 1.year) > (old + 5.minutes)
      assert_equal token, signed_cookie("remember_user_token").last
    end
  end

  test 'if both extend_remember_period and remember_across_browsers are false, sends a new token with old expire date' do
    swap Devise, :remember_across_browsers => false, :extend_remember_period => false, :remember_for => 1.year do
      user  = create_user_and_remember
      token = user.remember_token

      user.remember_created_at = old = 10.minutes.ago
      user.save!

      get users_path
      assert (cookie_expires("remember_user_token") - 1.year) < (old + 5.minutes)
      assert_not_equal token, signed_cookie("remember_user_token").last
    end
  end

  test 'do not remember other scopes' do
    user = create_user_and_remember
    get root_path
    assert_response :success
    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)
  end

  test 'do not remember with invalid token' do
    user = create_user_and_remember('add')
    get users_path
    assert_not warden.authenticated?(:user)
    assert_redirected_to new_user_session_path
  end

  test 'do not remember with expired token' do
    user = create_user_and_remember
    swap Devise, :remember_for => 0 do
      get users_path
      assert_not warden.authenticated?(:user)
      assert_redirected_to new_user_session_path
    end
  end

  test 'forget the user before sign out' do
    user = create_user_and_remember
    get users_path
    assert warden.authenticated?(:user)
    get destroy_user_session_path
    assert_not warden.authenticated?(:user)
    assert_nil user.reload.remember_token
    assert_nil warden.cookies['remember_user_token']
  end

  test 'do not remember the user anymore after forget' do
    user = create_user_and_remember
    get users_path
    assert warden.authenticated?(:user)
    get destroy_user_session_path
    get users_path
    assert_not warden.authenticated?(:user)
    assert_nil warden.cookies['remember_user_token']
  end
end
