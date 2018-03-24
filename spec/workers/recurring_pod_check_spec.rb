# frozen_string_literal: true

describe Workers::RecurringPodCheck do
  before do
    @pods = (0..4).map do
      FactoryGirl.build(:pod).tap { |pod|
        expect(pod).to receive(:test_connection!)
      }
    end
    allow(Pod).to receive(:find_in_batches).and_yield(@pods)
  end

  it "performs a connection test on all existing pods" do
    Workers::RecurringPodCheck.new.perform
  end
end
