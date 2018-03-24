# frozen_string_literal: true

module DebuggingCukeHelpers
  def start_debugging
    require 'pry'
    binding.pry
    true
  end
end

World(DebuggingCukeHelpers)


When 'I debug' do
  start_debugging
end

When /^I wait for (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
  warn "\nDELETEME - this step is for debugging, only!\n"
end

When /^I open the error console$/ do
  page.driver.browser.action.
    key_down(:control).
    key_down(:shift).
    send_keys("j").
    key_up(:shift).
    key_up(:control).perform
end

When /^I open the web console$/ do
  page.driver.browser.action.
    key_down(:control).
    key_down(:shift).
    send_keys("k").
    key_up(:shift).
    key_up(:control).perform
end
