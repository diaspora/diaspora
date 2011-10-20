
require 'spec_helper'

#NOTE;why is it not auto loadeded?
require File.join(Rails.root, 'lib', 'publisher')

describe Publisher do
  before do
    @publisher = Publisher.new(alice)
  end

  describe '#open?' do
    it 'defaults to closed' do
      @publisher.open?.should be_false
    end

    it 'listens to the opts' do
      Publisher.new(alice, :open => true).open?.should be_true
    end
  end

  describe "#prefill" do
    it 'defaults to nothing' do
      @publisher.prefill.should be_blank
    end

    it 'is settable' do
      Publisher.new(alice, :prefill => "party!").prefill.should == "party!"
    end
  end

  describe "#public?" do
    it 'defaults to false' do
      @publisher.public?.should be_false
    end

    it 'listens to the opts' do
      Publisher.new(alice, :public => true).public?.should be_true
    end
  end
end
