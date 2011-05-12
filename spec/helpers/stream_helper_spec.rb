#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StreamHelper do
  before do
    @post = Factory(:status_message)
  end
  describe "#time_for_sort" do
    it "returns sort_order for an aspectscontroller" do
      sort_order = :stored_in_session
      stub!(:controller).and_return(AspectsController.new)
      stub!(:session).and_return({:sort_order => sort_order})
      @post.should_receive(sort_order)
      time_for_sort(@post)
    end
    it "returns post.created_at otherwise" do
      stub!(:controller).and_return(mock())
      time_for_sort(@post).should == @post.created_at
    end
  end
end
