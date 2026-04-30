# frozen_string_literal: true

describe RecurringPodCheckWorker do
  before do
    @pods = (0..4).map do
      FactoryBot.build(:pod).tap {|pod|
        expect(pod).to receive(:test_connection!)
      }
    end
    allow(Pod).to receive(:find_in_batches).and_yield(@pods)
  end

  it "performs a connection test on all existing pods" do
    RecurringPodCheckWorker.new.perform
  end
end
