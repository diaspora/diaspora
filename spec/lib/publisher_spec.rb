
require 'spec_helper'

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

  describe '#text' do
    it 'is a formatted version of the prefill' do
      p = Publisher.new(alice, :prefill => "@{alice; alice@pod.com}")
      p.text.should == "alice"
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
