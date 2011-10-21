require 'spec_helper'
require File.join(Rails.root, 'spec', 'shared_behaviors', 'stream')

describe Stream::Soup do
  before do
    @stream = Stream::Soup.new(Factory(:user), :max_time => Time.now, :order => 'updated_at')
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end
end
