#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

describe Postzord::Receiver do
  before do
    @receiver = Postzord::Receiver.new
  end

  describe "#perform!" do
    before do
      allow(@receiver).to receive(:receive!).and_return(true)
    end

    it "calls receive!" do
      expect(@receiver).to receive(:receive!)
      @receiver.perform!
    end
  end

  describe "#author_does_not_match_xml_author?" do
    before do
      @receiver.instance_variable_set(:@author, alice.person)
      allow(@receiver).to receive(:xml_author).and_return(alice.diaspora_handle)
    end

    it "should return false if the author matches" do
      allow(@receiver).to receive(:xml_author).and_return(alice.diaspora_handle)
      expect(@receiver.send(:author_does_not_match_xml_author?)).to be_falsey
    end

    it "should return true if the author does not match" do
      allow(@receiver).to receive(:xml_author).and_return(bob.diaspora_handle)
      expect(@receiver.send(:author_does_not_match_xml_author?)).to be_truthy
    end
  end

  describe "#relayable_without_parent?" do
    before do
      @receiver.instance_variable_set(:@author, alice.person)
    end

    it "should return false if object is not relayable" do
      @receiver.instance_variable_set(:@object, nil)
      expect(@receiver.send(:relayable_without_parent?)).to be_falsey
    end

    context "if object is relayable" do
      before do
        @comment = bob.build_comment(text: "yo", post: FactoryGirl.create(:status_message))
        @receiver.instance_variable_set(:@object, @comment)
      end

      it "should return false if object has parent" do
        expect(@receiver.send(:relayable_without_parent?)).to be_falsey
      end

      it "should return true if object has no parent" do
        @comment.parent = nil
        expect(@receiver.send(:relayable_without_parent?)).to be_truthy
      end
    end
  end
end
