require 'spec_helper'
require File.join(Rails.root, 'spec', 'shared_behaviors', 'stream')

describe Stream::Multi do
  before do
    @stream = Stream::Multi.new(Factory(:user), :max_time => Time.now, :order => 'updated_at')
  end


  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end

  describe '#is_in?' do
    it 'handles when the cache returns strings' do
      p = Factory(:status_message)
      @stream.should_receive(:aspects_post_ids).and_return([p.id.to_s])
      @stream.send(:is_in?, :aspects, p).should be_true
    end
  end
end
