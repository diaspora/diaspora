require 'spec_helper'
require 'extlib'

describe "#try_call" do
  describe "with an Object" do
    before :all do
      @receiver = Object.new
    end

    it "returns receiver itself" do
      @receiver.try_call.should == @receiver
    end
  end

  describe "with a number" do
    before :all do
      @receiver = 42
    end

    it "returns receiver itself" do
      @receiver.try_call.should == @receiver
    end
  end

  describe "with a String" do
    before :all do
      @receiver = "Ruby, programmer's best friend"
    end

    it "returns receiver itself" do
      @receiver.try_call.should == @receiver
    end
  end

  describe "with a hash" do
    before :all do
      @receiver = { :functional_programming => "FTW" }
    end

    it "returns receiver itself" do
      @receiver.try_call.should == @receiver
    end
  end

  describe "with a Proc" do
    before :all do
      @receiver = Proc.new { 5 * 7 }
    end

    it "returns result of calling of a proc" do
      @receiver.try_call.should == 35
    end
  end

  describe "with a Proc that takes 2 arguments" do
    before :all do
      @receiver = Proc.new { |one, other| one + other }
    end

    it "passes arguments to #call, returns result of calling of a proc" do
      @receiver.try_call(10, 20).should == 30
    end
  end

  describe "with a Proc that takes 3 arguments" do
    before :all do
      @receiver = Proc.new { |a, b, c| (a + b) * c }
    end

    it "passes arguments to #call, returns result of calling of a proc" do
      @receiver.try_call(10, 20, 3).should == 90
    end
  end
end
