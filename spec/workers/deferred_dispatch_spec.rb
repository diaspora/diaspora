require 'spec_helper'

describe Workers::DeferredDispatch do
  it 'handles non existing records gracefully' do
    expect do
      described_class.new.perform(alice.id, 'Comment', 0, {})
    end.to_not raise_error
  end
end
