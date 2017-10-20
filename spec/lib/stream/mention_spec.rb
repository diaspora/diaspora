# frozen_string_literal: true

require Rails.root.join('spec', 'shared_behaviors', 'stream')

describe Stream::Mention do
  before do
    @stream = Stream::Mention.new(alice, :max_time => Time.now, :order => 'updated_at')
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end
end
