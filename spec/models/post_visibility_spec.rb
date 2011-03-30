#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
require 'spec_helper'

describe PostVisibility do
  before do
    @alice = alice
    @bob = bob

    @status = @alice.post(:status_message, :text => "hello", :public => true, :to => @alice.aspects.first)
    @vis = @status.post_visibilities.first
    @vis.hidden = true
    @vis.save
  end

  it 'is default scoped to not-hidden' do
    PostVisibility.where(:id => @vis.id).should == [] 
    PostVisibility.unscoped.where(:id => @vis.id).should == [@vis] 
  end
end
