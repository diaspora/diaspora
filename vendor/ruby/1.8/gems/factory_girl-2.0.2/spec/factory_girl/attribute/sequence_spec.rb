require 'spec_helper'

describe FactoryGirl::Attribute::Sequence do
  before do
    @name     = :first_name
    @sequence = :name
    FactoryGirl.register_sequence(FactoryGirl::Sequence.new(@sequence, 5) { |n| "Name #{n}" })
    @attr  = FactoryGirl::Attribute::Sequence.new(@name, @sequence)
  end

  it "should have a name" do
    @attr.name.should == @name
  end

  it "assigns the next value in the sequence" do
    proxy = "proxy"
    stub(proxy).set
    @attr.add_to(proxy)
    proxy.should have_received.set(@name, "Name 5")
  end
end
