RSpec::Matchers.define :have_path do |expected|
  match do |actual|
    start_time = Time.now
    until actual.current_path == expected
      return false if (Time.now-start_time) > Capybara.default_wait_time
      sleep 0.05
    end
    true
  end

  failure_message_for_should do |actual|
    "expected #{actual.inspect} to have path #{expected.inspect} but was #{actual.current_path.inspect}"
  end
  failure_message_for_should_not do |actual|
    "expected #{actual.inspect} to not have path #{expected.inspect} but it had"
  end
end
