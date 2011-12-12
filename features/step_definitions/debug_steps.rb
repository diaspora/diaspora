When 'I debug' do
  require 'ruby-debug'
  debugger
  true
end

When /^I wait for (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end
