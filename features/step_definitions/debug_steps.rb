When 'I debug' do
  require 'ruby-debug'
  debugger
  true
end

When /^I sleep for (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
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
