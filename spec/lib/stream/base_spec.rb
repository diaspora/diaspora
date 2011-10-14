require 'spec_helper'
require File.join(Rails.root, 'spec', 'shared_behaviors', 'stream')
describe Stream::Base do
  before do
    @stream = Stream::Base.new(stub)
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end
end
