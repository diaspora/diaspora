require 'spec_helper'
require Rails.root.join('spec', 'shared_behaviors', 'stream')

describe Stream::Public do
  before do
    @stream = Stream::Public.new(alice)
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end
end
