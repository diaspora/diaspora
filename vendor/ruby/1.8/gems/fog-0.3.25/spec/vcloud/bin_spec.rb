require File.dirname(__FILE__) + '/spec_helper'

describe Vcloud do
  it { should be_initialized }

  it { should have_at_least(1).services }

  describe "#registered_services" do
    subject { Vcloud.registered_services }

    it { should have_at_least(1).services }
  end

  describe "when indexing it like an array" do
    describe "with a service that exists" do
      it "should return something when indexed with a configured service" do
        Vcloud[:ecloud].should_not be_nil
      end
    end

    describe "with a service that does not exist" do
      it "should raise an ArgumentError" do
        lambda {Vcloud[:foozle]}.should raise_error(ArgumentError)
      end
    end

  end
end
