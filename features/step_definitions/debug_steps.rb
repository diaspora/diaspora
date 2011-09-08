When 'I debug' do
  debugger
  true
end

When /^I wait for (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end
