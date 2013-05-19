#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Postzord::Receiver do
  before do
    @receiver = Postzord::Receiver.new
  end

  describe "#perform!" do
    before do
      @receiver.stub(:receive!).and_return(true)
    end

    it 'calls receive!' do
      @receiver.should_receive(:receive!)
      @receiver.perform!
    end
  end
end

