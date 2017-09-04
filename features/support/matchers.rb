# frozen_string_literal: true

RSpec::Matchers.define :have_path do |expected|
  match do |actual|
    await_condition { actual.current_path == expected }
  end

  failure_message_for_should do |actual|
    "expected #{actual.inspect} to have path #{expected.inspect} but was #{actual.current_path.inspect}"
  end
  failure_message_for_should_not do |actual|
    "expected #{actual.inspect} to not have path #{expected.inspect} but it had"
  end
end

RSpec::Matchers.define :have_path_in do |expected|
  match do |actual|
    await_condition { expected.include? actual.current_path }
  end

  failure_message_for_should do |actual|
    "expected #{actual.inspect} to have path in #{expected.inspect} but was #{actual.current_path.inspect}"
  end
  failure_message_for_should_not do |actual|
    "expected #{actual.inspect} to not have path in #{expected.inspect} but it had"
  end
end

RSpec::Matchers.define :have_value do |expected|
  match do |actual|
    await_condition { actual.value && actual.value.include?(expected) }
  end

  failure_message_for_should do |actual|
    "expected #{actual.inspect} to have value #{expected.inspect} but was #{actual.value.inspect}"
  end
  failure_message_for_should_not do |actual|
    "expected #{actual.inspect} to not have value #{expected.inspect} but it had"
  end
end

def await_condition &condition
  start_time = Time.zone.now
  until condition.call
    return false if (Time.zone.now - start_time) > Capybara.default_max_wait_time
    sleep 0.05
  end
  true
end
