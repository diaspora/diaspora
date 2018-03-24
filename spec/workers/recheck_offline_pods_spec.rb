# frozen_string_literal: true

describe Workers::RecheckScheduledPods do
  it "performs a connection test on all scheduled pods" do
    (0..4).map { FactoryGirl.create(:pod) }
    FactoryGirl.create(:pod, scheduled_check: true)

    expect_any_instance_of(Pod).to receive(:test_connection!)
    Workers::RecheckScheduledPods.new.perform
  end
end
