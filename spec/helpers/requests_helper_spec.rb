#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

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

  describe "#relationship_flow" do
    let(:tom){ Factory(:user, :email => 'tom@tom.joindiaspora.com') }

    before do
      stub!(:current_user).and_return(tom)
    end

    it 'should return the correct tag and url for a given address' do
      relationship_flow('tom@tom.joindiaspora.com')[:friend].receive_url.should include("receive/user")
    end
  end
end
