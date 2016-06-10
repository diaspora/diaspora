#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require Rails.root.join("spec", "shared_behaviors", "relayable")

describe RelayableRetraction do
  before do
    @local_luke, @local_leia, @remote_raphael = set_up_friends
    @remote_parent = FactoryGirl.build(:status_message, :author => @remote_raphael)
    @local_parent = @local_luke.post :status_message, :text => "hi", :to => @local_luke.aspects.first
  end

  context "when retracting a comment" do
    before do
      skip # TODO
      @comment= @local_luke.comment!(@local_parent, "yo")
      @retraction= @local_luke.retract(@comment)
    end

    describe "#parent" do
      it "delegates to to target" do
        expect(@retraction.target).to receive(:parent)
        @retraction.parent
      end
    end

    describe "#parent_author" do
      it "delegates to target" do
        expect(@retraction.target).to receive(:parent_author)
        @retraction.parent_author
      end
    end

    describe "#subscribers" do
      it "delegates it to target" do
        expect(@retraction.target).to receive(:subscribers)
        @retraction.subscribers
      end
    end
  end
end
