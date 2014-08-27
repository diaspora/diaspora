#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Workers::PublishToHub do
  describe '.perform' do
    it 'calls pubsubhubbub' do
      url = "http://publiczone.com/"
      m = double()

      expect(m).to receive(:publish).with(url+'.atom')
      expect(Pubsubhubbub).to receive(:new).with(AppConfig.environment.pubsub_server).and_return(m)
      Workers::PublishToHub.new.perform(url)
    end
  end
end
