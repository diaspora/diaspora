require 'spec_helper'

module Cucumber
  describe Broadcaster do
    before do
      @receiver = mock('receiver')
      @broadcaster = Broadcaster.new([@receiver])
    end
    
    it "should broadcast methods to registered objects" do
      @receiver.should_receive(:konbanwa).with('good evening')
      @broadcaster.konbanwa('good evening')
    end
  end
end
