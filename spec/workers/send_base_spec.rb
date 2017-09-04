# frozen_string_literal: true

describe Workers::SendBase do
  it "retries first time after at least 256 seconds" do
    retry_delay = Workers::SendBase.new.send(:seconds_to_delay, 1)
    expect(retry_delay).to be >= 256
    expect(retry_delay).to be < 316
  end

  it "increases the interval for each retry" do
    expect(Workers::SendBase.new.send(:seconds_to_delay, 2)).to be >= 625
    expect(Workers::SendBase.new.send(:seconds_to_delay, 3)).to be >= 1_296
    expect(Workers::SendBase.new.send(:seconds_to_delay, 4)).to be >= 2_401
    expect(Workers::SendBase.new.send(:seconds_to_delay, 5)).to be >= 4_096
    expect(Workers::SendBase.new.send(:seconds_to_delay, 6)).to be >= 6_561
    expect(Workers::SendBase.new.send(:seconds_to_delay, 7)).to be >= 10_000
    expect(Workers::SendBase.new.send(:seconds_to_delay, 8)).to be >= 14_641
    expect(Workers::SendBase.new.send(:seconds_to_delay, 9)).to be >= 20_736
  end
end
