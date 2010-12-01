Around('@fast') do |scenario, block|
  Timeout.timeout(0.5) do
    block.call
  end
end

When /^I take (.+) seconds to complete$/ do |seconds|
  sleep seconds.to_f
end
