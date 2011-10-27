
require 'spec_helper'

#NOTE;why is it not auto loadeded?
require File.join(Rails.root, 'lib', 'publisher')

describe Publisher do
  before do
    @publisher = Publisher.new(alice)
  end



  describe "#prefill" do
    it 'defaults to nothing' do
      @publisher.prefill.should be_blank
    end

    it 'is settable' do
      Publisher.new(alice, :prefill => "party!").prefill.should == "party!"
    end
  end


  ["open", "public", "explain"].each do |property|
    describe "##{property}?" do
      it 'defaults to closed' do
        @publisher.send("#{property}?".to_sym).should be_false
      end

      it 'listens to the opts' do
        Publisher.new(alice, {property.to_sym => true}).send("#{property}?".to_sym).should be_true
      end
    end
  end

end
