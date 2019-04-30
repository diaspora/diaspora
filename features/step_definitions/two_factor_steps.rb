# frozen_string_literal: true

When /^I scan the QR code and fill in a valid TOTP token for "([^"]*)"$/ do |email|
  @me = find_user email
  fill_in "user_code", with: @me.current_otp
end

When /^I fill in a valid TOTP token for "([^"]*)"$/ do |username|
  @me = find_user username
  fill_in "user_otp_attempt", with: @me.current_otp
end

When /^I fill in an invalid TOTP token$/ do
  fill_in "user_otp_attempt", with: "c0ffee"
end

When /^I fill in a recovery code from "([^"]*)"$/ do |username|
  @me = find_user username
  @codes = @me.generate_otp_backup_codes!
  @me.save!
  fill_in "user_otp_attempt", with: @codes.first
end

When /^I confirm activation$/ do
  find(".btn-primary", match: :first).click
end

When /^2fa is activated for "([^"]*)"$/ do |username|
  @me = find_user username
  @me.otp_secret = User.generate_otp_secret(32)
  @me.otp_required_for_login = true
  @me.save!
end

When /^I fill in username "([^"]*)" and password "([^"]*)"$/ do |username, password|
  fill_in "user_username", with: username
  fill_in "user_password", with: password
end

Then /^I should see a list of recovery codes$/ do
  find(".recovery-codes", match: :first)
  find(".recovery-codes li samp", match: :first)
end

When /^I press the recovery code generate button$/ do
  find(".btn-default", match: :first).click
end

def find_user(username)
  User.find_by(username: username) || User.find_by(email: username)
end
