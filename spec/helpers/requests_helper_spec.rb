#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require 'spec_helper'

include RequestsHelper

describe RequestsHelper do

  before do

    stub_success("tom@tom.joindiaspora.com")
    stub_success("evan@status.net")
    @tom = Redfinger.finger('tom@tom.joindiaspora.com')
    @evan = Redfinger.finger('evan@status.net')
  end

  describe "profile" do
    it 'should detect how to subscribe to a diaspora or webfinger profile' do
      subscription_mode(@tom).should == :friend
      subscription_mode(@evan).should == :none
    end
  end
end
