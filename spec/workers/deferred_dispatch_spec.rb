# frozen_string_literal: true

describe Workers::DeferredDispatch do
  it "handles non existing records gracefully" do
    expect {
      described_class.new.perform(alice.id, "Comment", 0, {})
    }.to_not raise_error
  end
end
