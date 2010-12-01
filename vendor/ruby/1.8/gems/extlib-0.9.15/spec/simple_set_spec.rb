require 'spec_helper'
require 'extlib/simple_set'

describe Extlib::SimpleSet do

  before do
    @s = Extlib::SimpleSet.new("Initial")
  end

  describe "#initialize" do
    it 'adds passed value to the set' do
      @new_generation_vms = Extlib::SimpleSet.new(["Rubinius", "PyPy", "Parrot"])

      @new_generation_vms.should have_key("Rubinius")
      @new_generation_vms.should have_key("PyPy")
      @new_generation_vms.should have_key("Parrot")
    end
  end

  describe "#<<" do
    it "adds value to the set" do
      @s << "Hello"
      @s.to_a.should be_include("Hello")
    end

    it 'sets true mark on the key' do
      @s << "Fun"
      @s["Fun"].should be_true
    end
  end

  describe "#merge(other)" do
    it "preserves old values when values do not overlap" do
      @s.should have_key("Initial")
    end

    it 'adds new values from merged set' do
      @t = @s.merge(["Merged value"])
      @t.should have_key("Merged value")
    end

    it 'returns a SimpleSet instance' do
      @s.merge(["Merged value"]).should be_kind_of(Extlib::SimpleSet)
    end
  end

  describe "#inspect" do
    it "lists set values" do
      @s.inspect.should == "#<SimpleSet: {\"Initial\"}>"
    end
  end

  describe "#keys" do
    it 'is aliased as to_a' do
      @s.to_a.should === @s.keys
    end
  end
end
