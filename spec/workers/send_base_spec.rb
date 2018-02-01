# frozen_string_literal: true

describe Workers::SendBase do
  it "retries first time after at least 256 seconds" do
    retry_delay = Workers::SendBase.new.send(:seconds_to_delay, 1)
    expect(retry_delay).to be >= 256
    expect(retry_delay).to be < 316
  end

  it "increases the interval for each retry" do
    (2..19).each do |count|
      expect(Workers::SendBase.new.send(:seconds_to_delay, count)).to be >= ((count + 3)**4)
    end

    # lets make some tests with explicit numbers to make sure the formula above works correctly
    # and increases the delay with the expected result
    expect(Workers::SendBase.new.send(:seconds_to_delay, 9)).to be >= 20_736
    expect(Workers::SendBase.new.send(:seconds_to_delay, 19)).to be >= 234_256
  end
end
